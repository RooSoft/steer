defmodule Steer.Repo.Queries.GetAllChannels do
  require Logger

  import Ecto.Query

  alias Steer.Lightning.Models, as: Models

  def get_query(options \\ []) do
    defaults = %{include_closed: false}
    options = Enum.into(options, defaults)

    get_all_channels(options)
  end

  defp get_all_channels(%{include_closed: true}) do
    from(c in Models.Channel,
      select: c
    )
  end

  defp get_all_channels(%{include_closed: false}) do
    from(c in Models.Channel,
      join: fi in subquery(forwards_in_subquery()),
      on: c.id == fi.channel_id,
      join: fo in subquery(forwards_out_subquery()),
      on: c.id == fo.channel_id,
      where: c.status != :closed,
      order_by: [
        desc:
          fragment(
            "SELECT coalesce(Max(v), '2000-01-01') FROM (VALUES (?), (?)) AS value(v)",
            fi.latest_timestamp,
            fo.latest_timestamp
          )
      ],
      select: %{
        id: c.id,
        lnd_id: c.lnd_id,
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
        latest_forward_time:
          fragment(
            "SELECT Max(v) FROM (VALUES (?), (?)) AS value(v)",
            fi.latest_timestamp,
            fo.latest_timestamp
          ),
        status: c.status
      }
    )
  end

  defp forwards_in_subquery() do
    from(c in Models.Channel,
      left_join: f in assoc(c, :forwards_in),
      group_by: c.id,
      select: %{
        channel_id: c.id,
        forward_count: count(f.id),
        latest_timestamp: max(f.time)
      }
    )
  end

  defp forwards_out_subquery() do
    from(c in Models.Channel,
      left_join: f in assoc(c, :forwards_out),
      group_by: c.id,
      select: %{
        channel_id: c.id,
        forward_count: count(f.id),
        latest_timestamp: max(f.time)
      }
    )
  end
end
