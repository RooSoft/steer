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
    Logger.warn("Trying to connect to the node...")

    # If the connect method fails, Steer.Lightning will crash and be restarted by the supervisor
    Steer.Lightning.connect()

    Logger.warn("in DiagnosticsLive after connect...")

    Steer.Lightning.update_cache()

    Logger.warn("This will not get displayed")

    { :noreply, socket  }
  end

end
