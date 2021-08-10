defmodule Steer.Lnd.Channel do
  def convert(channel) do
    channel
    |> convert_channel
  end

  def convert_list(lnd_channels) do
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

  def activate_by_channel_point(channels, channel_point_struct, is_active) do
    { :funding_txid_bytes, funding_txid } = channel_point_struct.funding_txid

    txid = funding_txid
    |> :binary.bin_to_list
    |> Enum.reverse
    |> :binary.list_to_bin
    |> Base.encode16
    |> String.downcase

    channel_point = "#{txid}:#{channel_point_struct.output_index}"

    channels
    |> Enum.map(fn channel ->
      if channel.channel_point == channel_point do
        channel |> Map.put(:active, is_active)
      else
        channel
      end
    end)
  end

  defp sort_algo(channel1, channel2)
    when length(channel1.forwards) > 0
    and length(channel2.forwards) > 0 do

    [channel1_forward | _] = channel1.forwards
    [channel2_forward | _] = channel2.forwards

    channel1_forward.timestamp > channel2_forward.timestamp
  end

  defp sort_algo(channel1, channel2)
    when length(channel1.forwards) == 0
    and length(channel2.forwards) > 0 do

    false
  end

  defp sort_algo(channel1, channel2)
    when length(channel1.forwards) > 0
    and length(channel2.forwards) == 0 do

    true
  end

  defp sort_algo(_, _) do
    false
  end

  defp create_map(lnd_channels) do
    lnd_channels
    |> Enum.map(&convert_channel/1)
  end

  defp convert_channel(channel) do
    %{
      id: channel.chan_id,
      node_pubkey: channel.remote_pubkey,
      local_balance: channel.local_balance,
      remote_balance: channel.remote_balance,
      capacity: channel.capacity,
      balance_percent: 100 * channel.local_balance / channel.capacity,
      active: channel.active,
      channel_point: channel.channel_point,
      show_forwards: false
    }
  end

  defp format_balances(channels) do
    channels
    |> Enum.map(fn channel ->
      formatted_local_balance = Number.SI.number_to_si(channel.local_balance, unit: "", precision: 1)
      formatted_remote_balance = Number.SI.number_to_si(channel.remote_balance, unit: "", precision: 1)
      formatted_capacity = Number.SI.number_to_si(channel.capacity, unit: "", precision: 1)
      formatted_balance_percent = Number.SI.number_to_si(channel.balance_percent, unit: "", precision: 1)

      channel
      |> Map.put(:formatted_local_balance, formatted_local_balance)
      |> Map.put(:formatted_remote_balance, formatted_remote_balance)
      |> Map.put(:formatted_capacity, formatted_capacity)
      |> Map.put(:formatted_balance_percent, formatted_balance_percent)
    end)
  end
end
