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
      order_by: [desc: fi.latest_timestamp],
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
        latest_forward_time: fi.latest_timestamp,
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

  def get_channel_forwards(channel_id) do
    all from f in Models.Forward,
      where: f.channel_in_id == ^channel_id or f.channel_out_id == ^channel_id,
      order_by: [desc: f.timestamp],
      preload: [:channel_in, :channel_out]
  end

  def get_latest_unconsolidated_forward do
    one from f in Models.Forward,
      where: f.consolidated == false,
      order_by: [asc: f.timestamp],
      limit: 1
  end

  def get_forwards_in_date_range(%{
    start_time: start_time,
    end_time: end_time
  }) do
    all from f in Models.Forward,
      where: f.timestamp >= ^start_time and f.timestamp < ^end_time,
      order_by: [desc: f.timestamp],
      preload: [:channel_in, :channel_out]
  end

  def get_channel_by_channel_point(channel_point) do
    one first from c in Models.Channel,
      where: c.channel_point == ^channel_point
  end

  def get_channel_by_lnd_id(lnd_id) do
    one first from c in Models.Channel,
      where: c.lnd_id == ^lnd_id
  end

  def update_channel(channel, changes) do
    changeset = Models.Channel.changeset(channel, changes)

    { :ok, channel } = update(changeset)

    channel
  end

  defp forwards_in_subquery() do
    from c in Models.Channel,
      left_join: f in assoc(c, :forwards_in),
      group_by: c.id,
      select: %{
        channel_id: c.id,
        forward_count: count(f.id),
        latest_timestamp: max(f.timestamp)
      }
  end

  defp forwards_out_subquery() do
    from c in Models.Channel,
      left_join: f in assoc(c, :forwards_out),
      group_by: c.id,
      select: %{
        channel_id: c.id,
        forward_count: count(f.id),
        latest_timestamp: max(f.timestamp)
      }
  end
end
