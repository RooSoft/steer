defmodule SteerWeb.DiagnosticsLive do
  use SteerWeb, :live_view
  require Logger

  @impl true
  @spec mount(any, any, Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def mount(_params, _session, socket) do
    { :ok, socket
    |> assign(:messages, [])
    |> set_connecting_flag(false) }
  end


  @impl true
  def handle_event("connect", _value, socket) do
    self() |> Steer.Lnd.Connection.initiate()

    { :noreply, socket |> set_connecting_flag(true) }
  end

  @impl true
  def handle_info({ :node_connection, { :connected, message } }, socket) do
    Logger.info(message)

    { :noreply, socket
      |> add_message(message)
      |> set_connecting_flag(false) }
  end

  @impl true
  def handle_info({ :node_connection, { :disconnected, message } }, socket) do
    Logger.info(message)

    { :noreply, socket
      |> add_message(message)
      |> set_connecting_flag(false) }
  end

  @impl true
  def handle_info({ :node_connection, { _, message } }, socket) do
    Logger.info(message)

    { :noreply, socket |> add_message(message) }
  end

  defp set_connecting_flag(socket, is_connecting) do
    socket
    |> assign(:connecting, is_connecting)
  end

  defp add_message(socket, message_text) do
    { :ok, now } = DateTime.now("Etc/UTC")

    message = %{time: now, text: message_text}

    socket
    |> assign(:messages, [message|socket.assigns.messages])
  end
end
