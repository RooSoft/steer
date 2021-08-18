defmodule Steer.Lightning do
  alias Steer.Repo

  alias Steer.Lightning.Models

  def sync() do
    Steer.Sync.Channel.sync
    Steer.Sync.Forward.sync
  end

  def get_all_channels() do
    Repo.get_all_channels()
    |> format_balances
  end

  def get_channel(id) do
    Repo.get_channel(id)
    |> format_channel_balance
  end

  def get_channel_forwards(channel_id) do
    channel = Repo.get_channel(channel_id)

    channel_id
    |> Repo.get_channel_forwards()
    |> format_forwards_balances
    |> contextualize_forwards(channel)
  end

  defp format_balances(channels) do
    channels
    |> Enum.map(&format_channel_balance/1)
  end

  defp format_channel_balance(channel) do
    capacity_in_sats = channel.capacity |> Decimal.div(1000)
    total_balance = Decimal.add(channel.local_balance, channel.remote_balance)
    balance_percent = Decimal.mult(Decimal.div(channel.local_balance, total_balance), 100)

    formatted_capacity = Number.SI.number_to_si(capacity_in_sats, unit: "", precision: 1)
    formatted_local_balance = Number.SI.number_to_si(channel.local_balance, unit: "", precision: 1)
    formatted_remote_balance = Number.SI.number_to_si(channel.remote_balance, unit: "", precision: 1)
    formatted_balance_percent = Number.SI.number_to_si(balance_percent, unit: "", precision: 1)

    channel
    |> Map.put(:formatted_capacity, formatted_capacity)
    |> Map.put(:formatted_local_balance, formatted_local_balance)
    |> Map.put(:formatted_remote_balance, formatted_remote_balance)
    |> Map.put(:formatted_balance_percent, formatted_balance_percent)
  end

  defp format_forwards_balances(forwards) do
    forwards
    |> Enum.map(&format_forward_balances/1)
  end

  defp format_forward_balances(forward) do
    amount_in_in_sats = Models.Forward.amount_in_in_sats(forward)
    amount_out_in_sats = Models.Forward.amount_out_in_sats(forward)
    fee_in_sats = Models.Forward.fee_in_sats(forward)

    formatted_amount_in = Number.SI.number_to_si(amount_in_in_sats, unit: "", precision: 1)
    formatted_amount_out = Number.SI.number_to_si(amount_out_in_sats, unit: "", precision: 1)
    formatted_fee = Number.SI.number_to_si(fee_in_sats, unit: "", precision: 1)

    forward
    |> Map.put(:formatted_amount_in, formatted_amount_in)
    |> Map.put(:formatted_amount_out, formatted_amount_out)
    |> Map.put(:formatted_fee, formatted_fee)
  end

  defp contextualize_forwards(forwards, channel) do
    forwards
    |> Enum.map(fn forward ->
      forward
      |> Models.Forward.contextualize_forward(channel)
    end)
  end
end
