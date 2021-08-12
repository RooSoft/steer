defmodule Steer.Lightning do

  def sync() do
    Steer.Sync.Channel.sync
    Steer.Sync.Forward.sync
  end
end
