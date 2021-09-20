defmodule SteerWeb.LndNodeStatusChannel do
  use SteerWeb, :channel

  require Logger

  alias SteerWeb.Endpoint

  @uptime_event_topic "uptime"
  @up_message "up"
  @down_message "down"

  @impl true
  def join("lnd_node_status:status", _payload, socket) do
    Endpoint.subscribe(@uptime_event_topic)

    send(self(), :after_join)

    {:ok, socket}
  end

  def join("lnd_node_status:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_info(:after_join, socket) do
    push(socket, "node_status", Steer.Lightning.get_node_status())

    {:noreply, socket}
  end

  @impl true
  def handle_info(%{
    topic: @uptime_event_topic,
    event: @up_message,
    payload: _payload
  }, socket) do
    socket |> broadcast("lnd_node_status:status", %{status: "UP"})

    { :noreply, socket }
  end

  @impl true
  def handle_info(%{
    topic: @uptime_event_topic,
    event: @down_message,
    payload: _payload
  }, socket) do
    socket |> broadcast("lnd_node_status:status", %{status: "DOWN"})

    { :noreply, socket }
  end


  @impl true
  def handle_info(%{
    topic: topic,
    event: event,
    payload: _payload
  }, socket) do
    Logger.warn "--- abnormal uptime event topic: #{topic} #{event} ---"

    { :noreply, socket }
  end
end
