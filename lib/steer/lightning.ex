defmodule Steer.Lightning do
  alias Steer.Repo
  alias Steer.Lightning.Models

  def sync() do
    Steer.Sync.Channel.sync
    Steer.Sync.Forward.sync

    IO.puts "Sync done at #{DateTime.utc_now()}"
  end

  def get_all_channels() do
    Repo.get_all_channels()
    |> format_balances
  end

  def get_channel(id) do
    Repo.get_channel(id)
    |> Models.Channel.format_balances
  end

  def get_channel_forwards(channel_id) do
    channel = Repo.get_channel(channel_id)

    channel_id
    |> Repo.get_channel_forwards()
    |> format_forwards_balances
    |> Models.Forward.contextualize_forwards(channel)
  end

  def get_latest_unconsolidated_forward do
    Repo.get_latest_unconsolidated_forward
  end

  defp format_balances(channels) do
    channels
    |> Enum.map(&Models.Channel.format_balances/1)
  end

  defp format_forwards_balances(forwards) do
    forwards
    |> Enum.map(&Models.Forward.format_balances/1)
  end
end
