defmodule Steer.Lightning do
  import Ecto.Query

  alias Steer.Repo, as: Repo
  alias Steer.Lightning.Models, as: Models

  def sync() do
    Steer.Sync.Channel.sync
  end

  def get_all_channels(_ \\ %{include_closed: false})

  def get_all_channels(%{include_closed: false}) do
    Repo.all from c in Models.Channel, where: c.status != :closed
  end

  def get_all_channels(%{include_closed: true}) do
    Repo.all from c in Models.Channel
  end

  def get_channel_by_channel_point(channel_point) do
    Repo.one first from c in Models.Channel,
      where: c.channel_point == ^channel_point
  end

  def update_channel(channel, changes) do
    changeset = Models.Channel.changeset(channel, changes)

    { :ok, channel } = Repo.update(changeset)

    channel
  end
end
