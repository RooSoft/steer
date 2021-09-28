defmodule SteerWeb.DiagnosticsLive do
  use SteerWeb, :live_view
  require Logger

  @impl true
  @spec mount(any, any, Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def mount(_params, _session, socket) do
    { :ok, socket }
  end


  @impl true
  def handle_event("connect", _value, socket) do
    Logger.info("Trying to connect to the node...")

    # If the connect method fails, Steer.Lightning will crash and be restarted by the supervisor
    case Steer.Lightning.connect() do
      :ok ->
        Logger.info("Node connection successful, doing sync and updating cache")
        Steer.Lightning.sync()
        Steer.Lightning.update_cache()
      _ ->
        Logger.info("Node connection failed")
    end

    { :noreply, socket  }
  end

end
