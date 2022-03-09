defmodule SteerWeb.DiagnosticsLive do
  use SteerWeb, :live_view
  require Logger

  import SteerWeb.DiagnosticsLive.About
  import SteerWeb.DiagnosticsLive.Graph
  import SteerWeb.DiagnosticsLive.Lnd

  alias Steer.GraphUpdater

  @graph_updater_pubsub_topic inspect(GraphUpdater)
  @graph_updater_pubsub_ready :ready

  @impl true
  @spec mount(any, any, Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def mount(_params, _session, socket) do
    GraphUpdater.subscribe()

    {:ok, vsn} = :application.get_key(:steer, :vsn)

    {:ok,
     socket
     |> assign(:version, vsn)
     |> assign(:messages, [])
     |> assign(:info, Steer.Lightning.get_info())
     |> assign(:node, Steer.Repo.get_local_node())
     |> assign(:graph_status, :ready)
     |> set_connecting_flag(false)}
  end

  @impl true
  def handle_event("connect", _value, socket) do
    self() |> Steer.Lnd.Connection.initiate()

    {:noreply, socket |> set_connecting_flag(true)}
  end

  @impl true
  def handle_event("refresh_graph", _value, socket) do
    GraphUpdater.download()

    {:noreply, socket}
  end

  @impl true
  def handle_info({@graph_updater_pubsub_topic, @graph_updater_pubsub_ready, _payload}, socket) do
    {
      :noreply,
      socket
      |> assign(:graph_status, @graph_updater_pubsub_ready)
    }
  end

  @impl true
  def handle_info({@graph_updater_pubsub_topic, message, payload}, socket) do
    IO.inspect(payload)

    {:noreply, socket |> assign(:graph_status, message)}
  end

  @impl true
  def handle_info({:node_connection, {:connected, message}}, socket) do
    Logger.info(message)

    {:noreply,
     socket
     |> add_message(message)
     |> set_connecting_flag(false)}
  end

  @impl true
  def handle_info({:node_connection, {:disconnected, message}}, socket) do
    Logger.info(message)

    {:noreply,
     socket
     |> add_message(message)
     |> set_connecting_flag(false)}
  end

  @impl true
  def handle_info({:node_connection, {_, message}}, socket) do
    Logger.info(message)

    {:noreply, socket |> add_message(message)}
  end

  defp set_connecting_flag(socket, is_connecting) do
    socket
    |> assign(:connecting, is_connecting)
  end

  defp add_message(socket, message_text) do
    {:ok, now} = DateTime.now("Etc/UTC")

    message = %{
      date: now |> format_date,
      time: now |> format_time,
      text: message_text
    }

    socket
    |> assign(:messages, [message | socket.assigns.messages])
  end

  defp format_date(date) do
    Enum.join(
      [
        date.year,
        date.month |> Integer.to_string() |> String.pad_leading(2, "0"),
        date.day |> Integer.to_string() |> String.pad_leading(2, "0")
      ],
      "/"
    )
  end

  defp format_time(date) do
    Enum.join(
      [
        date.hour |> Integer.to_string() |> String.pad_leading(2, "0"),
        date.minute |> Integer.to_string() |> String.pad_leading(2, "0"),
        date.second |> Integer.to_string() |> String.pad_leading(2, "0")
      ],
      ":"
    )
  end
end
