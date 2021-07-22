defmodule Steer.Lnd.Channel do
  def convert(lnd_channels) do
    lnd_channels
    |> create_map()
    |> format_balances()
  end

  def add_node_info(channel, node) do
    channel
    |> Map.put(:alias, node.alias)
  end

  def sort_by_latest_forward_descending(channels) do
    channels
    |> Enum.sort(fn channel1, channel2 ->
      [channel1_forward | _] = channel1.forwards
      [channel2_forward | _] = channel2.forwards

      channel1_forward.timestamp > channel2_forward.timestamp
    end)
  end

  def combine_forwards(channels, forwards) do
    channels
    |> add_empty_forward_list
    |> convert_channel_list_to_map
    |> add_forwards(forwards, :chan_id_in)
    |> add_forwards(forwards, :chan_id_out)
    |> map_to_list
    |> sort_forwards
    |> set_latest_forward_field
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
        active: channel.active,
        show_forwards: false,
        classes: %{
          colors: %{
            active: get_active_color_class(channel)
          }
        }
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

      channel
      |> Map.put(:forwards, sorted_forwards)
    end)
  end

  defp set_latest_forward_field(channels) do
    channels
    |> Enum.map(fn channel ->
      case Enum.any?(channel.forwards) do
        true ->
          [ latest_forward | _ ] = channel.forwards
          channel |> Map.put(:latest_forward, latest_forward)
        false ->
          channel
      end
    end)
  end

  defp get_active_color_class(%{ active: true }) do
    "bg-green-200"
  end

  defp get_active_color_class(%{ active: false }) do
    "bg-red-200"
  end
end
