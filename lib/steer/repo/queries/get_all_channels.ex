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
    from(
      Models.Channel
      |> with_cte("forwards", as: ^forwards_cte())
      |> join(:left, [c], f in "forwards", on: c.id == f.channel_id)
      |> where([c], c.status != :closed)
      |> order_by([c, f], [{:desc, f.latest}])
      |> select([c, f], %{
        id: c.id,
        lnd_id: c.lnd_id,
        alias: c.alias,
        color: c.color,
        is_private: c.is_private,
        is_initiator: c.is_initiator,
        status: c.status,
        capacity: c.capacity,
        local_balance: c.local_balance,
        remote_balance: c.remote_balance,
        node_pub_key: c.node_pub_key,
        forward_in_count: f.nb_input,
        forward_out_count: f.nb_output,
        latest_forward_in_time: f.latest_input,
        latest_forward_out_time: f.latest_input,
        latest_forward_time: f.latest
      })
    )
  end

  defp forwards_in_subquery() do
    from(c in Models.Channel,
      left_join: f in assoc(c, :forwards_in),
      group_by: c.id,
      select: %{
        channel_id: c.id,
        forward_count: count(f.id),
        latest_timestamp: max(f.timestamp_ns)
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
        latest_timestamp: max(f.timestamp_ns)
      }
    )
  end

  defp forwards_cte() do
    Models.Channel
    |> with_cte("forwards_in", as: ^forwards_in_subquery())
    |> with_cte("forwards_out", as: ^forwards_out_subquery())
    |> join(:left, [c], fi in "forwards_in", on: c.id == fi.channel_id)
    |> join(:left, [c], fo in "forwards_out", on: c.id == fo.channel_id)
    |> select([c, fi, fo], %{
      channel_id: c.id,
      nb_input: fi.forward_count,
      nb_output: fo.forward_count,
      latest_input: fi.latest_timestamp |> coalesce(0),
      latest_output: fo.latest_timestamp |> coalesce(0),
      latest:
        fragment(
          "SELECT Max(?, ?)",
          fi.latest_timestamp |> coalesce(0),
          fo.latest_timestamp |> coalesce(0)
        )
    })
  end
end
