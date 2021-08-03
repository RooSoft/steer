defmodule Steer.Lnd.Channel do
  def convert(lnd_channels) do
    lnd_channels
    |> create_map()
    |> format_balances()
  end

  def add_node_info(channel, node) do
    channel
    |> Map.put(:alias, node.alias)
    |> Map.put(:color, node.color)
  end

  def sort_by_latest_forward_descending(channels) do
    channels
    |> Enum.sort(&sort_algo/2)
  end

  def sort_algo(channel1, channel2)
    when length(channel1.forwards) > 0
    and length(channel2.forwards) > 0 do

    [channel1_forward | _] = channel1.forwards
    [channel2_forward | _] = channel2.forwards

    channel1_forward.timestamp > channel2_forward.timestamp
  end

  def sort_algo(channel1, channel2)
    when length(channel1.forwards) == 0
    and length(channel2.forwards) > 0 do

    false
  end

  def sort_algo(channel1, channel2)
    when length(channel1.forwards) > 0
    and length(channel2.forwards) == 0 do

    true
  end

  def sort_algo(_, _) do
    false
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
            active: get_active_color_class(channel),
            border: get_border_color_class(channel)
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

  defp get_active_color_class(%{ active: true }) do
    "bg-green-200"
  end

  defp get_active_color_class(%{ active: false }) do
    "bg-red-200"
  end

  defp get_border_color_class(%{ active: true }) do
    "border-green-500"
  end

  defp get_border_color_class(%{ active: false }) do
    "border-red-500"
  end
end
