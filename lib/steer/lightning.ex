defmodule Steer.Lightning do
  import Ecto.Query

  alias Steer.Repo, as: Repo
  alias Steer.Lightning.Models, as: Models

  def sync() do
    Steer.Sync.Channel.sync
  end

  def get_all_channels() do
    Repo.all from c in Models.Channel
  end
end
