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

  defp order_by(channels, order) do
    channels
    |> Enum.sort(&(Map.get(&1, order) >= Map.get(&2, order)))
  end
end
