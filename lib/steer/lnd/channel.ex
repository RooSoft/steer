defmodule Steer.Lnd.Channel do
  def convert(lnd_channels, [{:order_by, order}]) do
    lnd_channels
    |> create_map()
    |> format_balances()
    |> order_by(order)
  end

  def add_node_info(channel, node) do
    channel
    |> Map.put(:alias, node.alias)
  end

  def combine_forwards(channels, forwards) do
    channels
    |> add_empty_forward_list
    |> convert_channel_list_to_map
    |> add_forwards(forwards, :chan_id_in)
    |> add_forwards(forwards, :chan_id_out)
    |> map_to_list
    |> sort_forwards
  end

  defp add_forwards(channel_map, forwards, key) do
    forwards
    |> Enum.reduce(channel_map, fn forward, channel_map ->
      channel_id = Map.get(forward, key)

      channel_map
      |> maybe_add_forward(channel_id, forward)
    end)
  end

  defp create_map(lnd_channels) do
    lnd_channels
    |> Enum.map(fn channel ->
      %{
        id: channel.chan_id,
        node_pubkey: channel.remote_pubkey,
        local_balance: channel.local_balance,
        remote_balance: channel.remote_balance,
      }
    end)
  end

  defp format_balances(channels) do
    channels
    |> Enum.map(fn channel ->
      formatted_local_balance = Number.SI.number_to_si(channel.local_balance, unit: "", precision: 1)
      formatted_remote_balance = Number.SI.number_to_si(channel.remote_balance, unit: "", precision: 1)

      channel
      |> Map.put(:formatted_local_balance, formatted_local_balance)
      |> Map.put(:formatted_remote_balance, formatted_remote_balance)
    end)
  end

  defp add_empty_forward_list(channels) do
    channels
    |> Enum.map(fn channel ->
      channel |> Map.put(:forwards, [])
    end)
  end

  defp convert_channel_list_to_map(channels) do
    channels
    |> Enum.reduce(%{}, fn channel, acc ->
      acc
      |> Map.put(channel.id, channel)
    end)
  end

  defp maybe_add_forward(channel_map, nil, _) do
    channel_map
  end

  defp maybe_add_forward(channel_map, channel_id, forward) do
    channel = channel_map |> Map.get(channel_id)

    channel_map
    |> maybe_add_forward_to_map(channel_id, channel, forward)
  end

  defp maybe_add_forward_to_map(channel_map, _, nil, _) do
    channel_map
  end

  defp maybe_add_forward_to_map(channel_map, channel_id, channel, forward) do
    new_channel = channel
    |> Map.put(:forwards, [forward | channel.forwards])

    channel_map
    |> Map.put(channel_id, new_channel)
  end

  defp map_to_list(channel_map) do
    channel_map
    |> Map.values()
  end

  defp sort_forwards(channels) do
    channels
    |> Enum.map(fn channel ->
      sorted_forwards = channel.forwards
      |> Enum.sort(&(&1.timestamp >= &2.timestamp))

      IO.inspect sorted_forwards

      channel
      |> Map.put(:forwards, sorted_forwards)
    end)
  end

  defp order_by(channels, order) do
    channels
    |> Enum.sort(&(Map.get(&1, order) >= Map.get(&2, order)))
  end
end
