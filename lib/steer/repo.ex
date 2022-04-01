defmodule Steer.Repo do
  require Logger

  use Ecto.Repo,
    otp_app: :steer,
    adapter: Ecto.Adapters.SQLite3

  import Ecto.Query

  alias Steer.Lightning.Models, as: Models

  def init(_type, config) do
    {:ok, config}
  end

  def get_local_node() do
    one(from(c in Models.LocalNode))
  end

  def get_all_channels(options \\ []) do
    Steer.Repo.Queries.GetAllChannels.get_query(options)
    |> all
  end

  def get_channel(id) do
    one(
      from(c in Models.Channel,
        where: c.id == ^id
      )
    )
  end

  def get_channel_by_lnd_id(lnd_id) do
    one(
      from(c in Models.Channel,
        where: c.lnd_id == ^lnd_id
      )
    )
  end

  def get_channel_by_alias(node_alias) do
    one(
      from(c in Models.Channel,
        where: c.alias == ^node_alias
      )
    )
  end

  def get_channel_forwards(channel_id) do
    all(
      from(f in Models.Forward,
        where: f.channel_in_id == ^channel_id or f.channel_out_id == ^channel_id,
        order_by: [desc: f.timestamp_ns],
        preload: [:channel_in, :channel_out]
      )
    )
  end

  def get_latest_forward do
    one(
      from(f in Models.Forward,
        order_by: [desc: f.timestamp_ns],
        limit: 1
      )
    )
  end

  def get_oldest_unconsolidated_forward do
    one(
      from(f in Models.Forward,
        where: f.consolidated == false,
        order_by: [asc: f.timestamp_ns],
        limit: 1
      )
    )
  end

  def get_forwards_in_date_range(%{
        start_time: start_time,
        end_time: end_time
      }) do
    int_start_time = DateTime.from_naive!(start_time, "Etc/UTC") |> DateTime.to_unix(:nanosecond)
    int_end_time = DateTime.from_naive!(end_time, "Etc/UTC") |> DateTime.to_unix(:nanosecond)

    all(
      from(f in Models.Forward,
        where: f.timestamp_ns >= ^int_start_time and f.timestamp_ns < ^int_end_time,
        order_by: [desc: f.timestamp_ns],
        preload: [:channel_in, :channel_out]
      )
    )
  end

  def get_htlc_forwards_with_statuses(options \\ []) do
    Steer.Repo.Queries.GetHtlcForwardsWithStatuses.get_query(options)
    |> all
  end

  def get_link_fails do
    all(
      from(lf in Models.HtlcLinkFail,
        join: htlc in Models.HtlcEvent,
        on: lf.htlc_event_id == htlc.id,
        left_join: ci in Models.Channel,
        on: ci.id == htlc.channel_in_id,
        left_join: co in Models.Channel,
        on: co.id == htlc.channel_out_id,
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
      )
    )
  end

  def mark_forwards_as_consolidated(forward_ids) do
    query =
      from(f in Models.Forward,
        where: f.id in ^forward_ids
      )

    update_all(query,
      set: [consolidated: true]
    )
  end

  def mark_date_forwards_as_consolidated(date) do
    int_date =
      date
      |> DateTime.new!(~T[00:00:00], "Etc/UTC")
      |> DateTime.to_unix(:nanosecond)

    query =
      from(f in Models.Forward,
        where: f.timestamp_ns / 1000 == ^int_date / 1000
      )

    update_all(query,
      set: [consolidated: true]
    )
  end

  def get_channel_by_channel_point(channel_point) do
    one(
      first(
        from(c in Models.Channel,
          where: c.channel_point == ^channel_point
        )
      )
    )
  end

  def update_channel(channel, changes) do
    changeset = Models.Channel.changeset(channel, changes)

    {:ok, channel} = update(changeset)

    channel
  end

  def insert_htlc_event(changes) do
    changeset = Models.HtlcEvent.changeset(%Models.HtlcEvent{}, changes)

    {:ok, htlc_event} = insert(changeset)

    htlc_event
  end

  def insert_htlc_forward(changes) do
    changeset = Models.HtlcForward.changeset(%Models.HtlcForward{}, changes)

    {:ok, htlc_forward} = insert(changeset)

    htlc_forward
  end

  def insert_htlc_link_fail(changes) do
    changeset = Models.HtlcLinkFail.changeset(%Models.HtlcLinkFail{}, changes)

    {:ok, htlc_link_fail} = insert(changeset)

    htlc_link_fail
  end
end
