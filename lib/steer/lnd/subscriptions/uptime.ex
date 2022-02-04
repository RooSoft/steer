defmodule Steer.Lnd.Subscriptions.Uptime do
  use GenServer
  require Logger

  @topic inspect(__MODULE__)

  @up_message :up
  @down_message :down

  def start() do
    {:ok, subscription} = GenServer.start(__MODULE__, nil, name: __MODULE__)

    Process.monitor(subscription)
  end

  def stop(reason \\ :normal, timeout \\ :infinity) do
    GenServer.stop(__MODULE__, reason, timeout)
  end

  def init(_) do
    LndClient.subscribe_uptime(%{pid: self()})

    send(self(), :up)

    {:ok, %{is_up: true}}
  end

  def is_up() do
    GenServer.call(__MODULE__, :is_up)
  end

  def handle_call(:is_up, _from, %{is_up: is_up} = state) do
    {:reply, is_up, state}
  end

  def handle_info(:up, state) do
    broadcast(@up_message)

    {
      :noreply,
      state
      |> Map.put(:is_up, true)
    }
  end

  def handle_info(:down, state) do
    broadcast(@down_message)

    {
      :noreply,
      state
      |> Map.put(:is_up, false)
    }
  end

  def handle_info({:DOWN, _ref, :process, _subscription, reason}, state) do
    Logger.error("Uptime subscription is DOWN and shouldn't be")
    IO.inspect(reason)
    Logger.info("Restarting uptime subscription")

    start()

    {:noreply, state}
  end

  def handle_info(_event, state) do
    write_in_yellow("--------- got an unknown state event")

    {:noreply, state}
  end

  defp write_in_yellow(message) do
    Logger.info(IO.ANSI.yellow_background() <> IO.ANSI.black() <> message <> IO.ANSI.reset())
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Steer.PubSub, @topic)
  end

  defp broadcast(message) do
    Phoenix.PubSub.broadcast(Steer.PubSub, @topic, {:uptime, message})
  end
end
