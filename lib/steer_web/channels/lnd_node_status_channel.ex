defmodule SteerWeb.LndNodeStatusChannel do
  use SteerWeb, :channel

  require Logger

  @up_message :up
  @down_message :down

  @impl true
  def join("lnd_node_status:status", _payload, socket) do
    Steer.Lnd.Subscriptions.Uptime.subscribe()

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
  def handle_info({:uptime, @up_message}, socket) do
    socket |> broadcast("lnd_node_status:status", %{status: "UP"})

    IO.puts("GOT A UP MESSAGE")

    {:noreply, socket}
  end

  @impl true
  def handle_info({:uptime, @down_message}, socket) do
    socket |> broadcast("lnd_node_status:status", %{status: "DOWN"})

    IO.puts("GOT A DOWN MESSAGE")

    {:noreply, socket}
  end
end
