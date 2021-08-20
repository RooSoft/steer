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
    |> Models.Channel.format_balances
  end

  def get_channel(id) do
    Repo.get_channel(id)
    |> Models.Channel.format_balances
  end

  def get_channel_forwards(channel_id) do
    channel = Repo.get_channel(channel_id)

    channel_id
    |> Repo.get_channel_forwards()
    |> Models.Forward.format_balances
    |> Models.Forward.contextualize_forwards(channel)
  end

  def get_latest_unconsolidated_forward do
    Repo.get_latest_unconsolidated_forward
  end
end
