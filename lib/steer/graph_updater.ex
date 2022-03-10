defmodule Steer.GraphUpdater do
  use Supervisor

  alias Steer.GraphUpdater.Manager

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      Steer.GraphUpdater.Manager,
      Steer.GraphUpdater.Runner
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def get_status do
    Manager.get_status()
  end

  def refresh do
    Manager.refresh()
  end

  def subscribe do
    Manager.subscribe()
  end
end
