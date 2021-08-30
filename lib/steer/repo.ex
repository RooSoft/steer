defmodule Steer.Repo do
  require Logger
  use Ecto.Repo,
    otp_app: :steer,
    adapter: Ecto.Adapters.Postgres

  import Ecto.Query

  alias Steer.Lightning.Models, as: Models

  def init(_type, config) do
    database_url = System.get_env("DATABASE_URL")
    if database_url == nil do
      Logger.debug "$DATABASE_URL not set, using config"
      {:ok, config}
    else
      Logger.debug "Configuring database using $DATABASE_URL"
      Logger.debug database_url
      {:ok, Keyword.put(config, :url, database_url)}
    end
  end

  def get_all_channels(_ \\ %{include_closed: false})

  def get_all_channels(%{include_closed: false}) do
    all from c in Models.Channel,
      join: fi in subquery(forwards_in_subquery()), on: c.id == fi.channel_id,
      join: fo in subquery(forwards_out_subquery()), on: c.id == fo.channel_id,
      where: c.status != :closed,
      order_by: [desc: fragment(
        "SELECT coalesce(Max(v), '2000-01-01') FROM (VALUES (?), (?)) AS value(v)",
        fi.latest_timestamp,
        fo.latest_timestamp)],
      select: %{
        id: c.id,
        alias: c.alias,
        color: c.color,
        capacity: c.capacity,
        local_balance: c.local_balance,
        remote_balance: c.remote_balance,
        node_pub_key: c.node_pub_key,
        forward_in_count: fi.forward_count,
        forward_out_count: fo.forward_count,
        latest_forward_in_time: fi.latest_timestamp,
        latest_forward_out_time: fo.latest_timestamp,
        latest_forward_time: fragment(
          "SELECT Max(v) FROM (VALUES (?), (?)) AS value(v)",
          fi.latest_timestamp,
          fo.latest_timestamp),
        status: c.status
      }
  end

  def get_all_channels(%{include_closed: true}) do
    all from c in Models.Channel
  end

  def get_channel(id) do
    one from c in Models.Channel,
      where: c.id == ^id
  end

  def get_channel_by_lnd_id(lnd_id) do
    one from c in Models.Channel,
      where: c.lnd_id == ^lnd_id
  end

  def get_channel_forwards(channel_id) do
    all from f in Models.Forward,
      where: f.channel_in_id == ^channel_id or f.channel_out_id == ^channel_id,
      order_by: [desc: f.timestamp_ns],
      preload: [:channel_in, :channel_out]
  end

  def get_latest_forward do
    one from f in Models.Forward,
      order_by: [desc: f.timestamp_ns],
      limit: 1
  end

  def get_latest_unconsolidated_forward do
    one from f in Models.Forward,
      where: f.consolidated == false,
      order_by: [desc: f.timestamp_ns],
      limit: 1
  end

  def get_forwards_in_date_range(%{
    start_time: start_time,
    end_time: end_time
  }) do
    all from f in Models.Forward,
      where: f.time >= ^start_time and f.time < ^end_time,
      order_by: [desc: f.timestamp_ns],
      preload: [:channel_in, :channel_out]
  end

  def get_htlc_forwards_with_statuses do
    all from hf in Models.HtlcForward,
      join: htlc in Models.HtlcEvent, on:
        hf.htlc_event_id == htlc.id,
      left_join: fail in Models.HtlcEvent, on:
        fail.htlc_in_id == htlc.htlc_in_id
        and fail.htlc_out_id == htlc.htlc_out_id
        and fail.type == :forward_fail,
      left_join: settle in Models.HtlcEvent, on:
        settle.htlc_in_id == htlc.htlc_in_id
        and settle.htlc_out_id == htlc.htlc_out_id
        and settle.type == :settle,
      left_join: ci in Models.Channel, on:
        ci.id == htlc.channel_in_id,
      left_join: co in Models.Channel, on:
        co.id == htlc.channel_out_id,
      order_by: [desc: htlc.timestamp_ns],
      select: %{
        htlc_id: htlc.id,
        fail_id: fail.id,
        settle_id: settle.id,
        channel_in_id: ci.id,
        channel_in: ci.alias,
        channel_out_id: co.id,
        channel_out: co.alias,
        amount_in: hf.amount_in,
        amount_out: hf.amount_out,
        time: htlc.time,
        timestamp_ns: htlc.timestamp_ns
      }
  end

  def get_link_fails do
    all from lf in Models.HtlcLinkFail,
      join: htlc in Models.HtlcEvent, on:
        lf.htlc_event_id == htlc.id,
      left_join: ci in Models.Channel, on:
        ci.id == htlc.channel_in_id,
      left_join: co in Models.Channel, on:
        co.id == htlc.channel_out_id,
      order_by: [desc: htlc.timestamp_ns],
      select: %{
        htlc_id: htlc.id,
        channel_in_id: ci.id,
        channel_in: ci.alias,
        channel_out_id: co.id,
        channel_out: co.alias,
        amount_in: lf.amount_in,
        amount_out: lf.amount_out,
        wire_failure: lf.wire_failure,
        failure_detail: lf.failure_detail,
        failure_string: lf.failure_string,
        time: htlc.time,
        timestamp_ns: htlc.timestamp_ns
      }
  end

  def mark_forwards_as_consolidated forward_ids do
    query =
      from f in Models.Forward,
      where: f.id in ^forward_ids

    update_all(query,
      set: [consolidated: true]
    )
  end

  def get_channel_by_channel_point(channel_point) do
    one first from c in Models.Channel,
      where: c.channel_point == ^channel_point
  end

  def update_channel(channel, changes) do
    changeset = Models.Channel.changeset(channel, changes)

    { :ok, channel } = update(changeset)

    channel
  end

  def insert_htlc_event changes do
    changeset = Models.HtlcEvent.changeset(%Models.HtlcEvent{}, changes)

    { :ok, htlc_event } = insert(changeset)

    htlc_event
  end

  def insert_htlc_forward changes do
    changeset = Models.HtlcForward.changeset(%Models.HtlcForward{}, changes)

    { :ok, htlc_forward } = insert(changeset)

    htlc_forward
  end

  def insert_htlc_link_fail changes do
    changeset = Models.HtlcLinkFail.changeset(%Models.HtlcLinkFail{}, changes)

    { :ok, htlc_link_fail } = insert(changeset)

    htlc_link_fail
  end

  defp forwards_in_subquery() do
    from c in Models.Channel,
      left_join: f in assoc(c, :forwards_in),
      group_by: c.id,
      select: %{
        channel_id: c.id,
        forward_count: count(f.id),
        latest_timestamp: max(f.time)
      }
  end

  defp forwards_out_subquery() do
    from c in Models.Channel,
      left_join: f in assoc(c, :forwards_out),
      group_by: c.id,
      select: %{
        channel_id: c.id,
        forward_count: count(f.id),
        latest_timestamp: max(f.time)
      }
  end
end
