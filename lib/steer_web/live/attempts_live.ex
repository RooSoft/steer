defmodule SteerWeb.AttemptsLive do
  use SteerWeb, :live_view
  require Logger

  @impl true
  @spec mount(any, any, Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def mount(_params, _session, socket) do
    {:ok,
      socket
      |> assign_attempts}
  end

  defp assign_attempts(socket) do
    socket
    |> assign(:attempts, Steer.Lightning.get_htlc_forwards_with_statuses())
  end
end
