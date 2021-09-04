defmodule Steer.LndUptimeSubscription do
  use GenServer
  require Logger

  alias SteerWeb.Endpoint

  @uptime_event_topic "uptime"
  @up_message "up"
  @down_message "down"

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def stop(reason \\ :normal, timeout \\ :infinity) do
    GenServer.stop(__MODULE__, reason, timeout)
  end

  def init(_) do
    LndClient.subscribe_uptime(%{pid: self()})

    { :ok, nil }
  end

  def handle_info(:up, state) do
    Steer.Lightning.sync()
    Steer.Lightning.update_cache()

    %{}
    |> broadcast(@uptime_event_topic, @up_message)

    {:noreply, state}
  end

  def handle_info(:down, state) do
    %{}
    |> broadcast(@uptime_event_topic, @down_message)

    {:noreply, state}
  end

  def handle_info(_event, state) do
    write_in_yellow "--------- got an unknown state event"

    {:noreply, state}
  end

  defp write_in_yellow message do
    Logger.info(IO.ANSI.yellow_background() <> IO.ANSI.black() <> message <> IO.ANSI.reset())
  end

  defp broadcast payload, topic, message do
    Endpoint.broadcast(topic, message, payload)

    payload
  end
end