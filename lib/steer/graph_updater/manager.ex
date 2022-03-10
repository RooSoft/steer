defmodule Steer.GraphUpdater.Manager do
  use GenServer

  alias Steer.GraphUpdater.Runner

  @pubsub %{
    topic: inspect(Steer.GraphUpdater),
    status: :status
  }

  @statuses %{
    ready: :ready,
    downloading: :downloading,
    importing: :importing,
    analyzing: :analyzing
  }

  def start_link(_opts) do
    GenServer.start_link(
      __MODULE__,
      update_status(%{}, @statuses.ready),
      name: __MODULE__
    )
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  def get_status do
    GenServer.call(__MODULE__, {:get_status})
  end

  def refresh do
    GenServer.cast(__MODULE__, {:refresh})
  end

  @impl true
  def handle_call({:get_status}, _from, state) do
    {:reply, get_status(state), state}
  end

  @impl true
  def handle_cast({:refresh}, state) do
    Runner.download(self())

    {
      :noreply,
      state
      |> update_status(@statuses.downloading)
    }
  end

  @impl true
  def handle_info({:graph_updater_runner_state, :downloaded}, state) do
    Runner.import(self())

    {
      :noreply,
      state
      |> update_status(@statuses.importing)
    }
  end

  @impl true
  def handle_info({:graph_updater_runner_state, :imported}, state) do
    Runner.analyze(self())

    {
      :noreply,
      state
      |> update_status(@statuses.analyzing)
    }
  end

  @impl true
  def handle_info({:graph_updater_runner_state, :analyzed}, state) do
    {
      :noreply,
      state
      |> update_status(:ready)
    }
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Steer.PubSub, @pubsub.topic)
  end

  defp broadcast(message) do
    Phoenix.PubSub.broadcast(Steer.PubSub, @pubsub.topic, {@pubsub.topic, message})
  end

  defp get_status(state) do
    state
    |> Map.get(:status)
  end

  defp update_status(state, status) do
    broadcast(status)

    state
    |> Map.put(:status, status)
  end
end
