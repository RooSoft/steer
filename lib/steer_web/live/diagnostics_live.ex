defmodule SteerWeb.DiagnosticsLive do
  use SteerWeb, :live_view
  require Logger

  @impl true
  @spec mount(any, any, Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def mount(_params, _session, socket) do
    { :ok, socket
      |> assign(:messages, [%{text: "this is a message"}]) }
  end


  @impl true
  def handle_event("connect", _value, socket) do
    socket = case Steer.Lightning.connect() do
      :ok ->
        socket = socket |> dispatch_message("Trying to connect to the node...")

        Steer.Lightning.sync()
        Steer.Lightning.update_cache()

        socket |> dispatch_message("Node connection successful")
      _ ->
        socket |> dispatch_message("Node connection failed")
    end

    { :noreply, socket }
  end

  defp dispatch_message(socket, message) do
    Logger.info(message)
    socket |> add_message(message)
  end

  defp add_message(socket, message_text) do
    message = %{text: message_text}

    socket
    |> assign(:messages, [message|socket.assigns.messages])
  end
end
