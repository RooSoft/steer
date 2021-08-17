defmodule Steer.Lightning do
  alias Steer.Repo

  def sync() do
    Steer.Sync.Channel.sync
    Steer.Sync.Forward.sync
  end

  def get_all_channels() do
    Repo.get_all_channels()
    |> format_balances
  end

  defp format_balances(channels) do
    channels
    |> Enum.map(fn channel ->
      IO.inspect(channel)
      capacity_in_sats = channel.capacity |> Decimal.div(1000)
      formatted_capacity = Number.SI.number_to_si(capacity_in_sats, unit: "", precision: 1)
#      formatted_local_balance = Number.SI.number_to_si(channel.local_balance, unit: "", precision: 1)
#      formatted_remote_balance = Number.SI.number_to_si(channel.remote_balance, unit: "", precision: 1)
#      formatted_balance_percent = Number.SI.number_to_si(channel.balance_percent, unit: "", precision: 1)

      channel
      |> Map.put(:formatted_capacity, formatted_capacity)
 #     |> Map.put(:formatted_local_balance, formatted_local_balance)
 #     |> Map.put(:formatted_remote_balance, formatted_remote_balance)
 #     |> Map.put(:formatted_balance_percent, formatted_balance_percent)
    end)
  end
end
