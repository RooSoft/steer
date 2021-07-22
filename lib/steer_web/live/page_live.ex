defmodule SteerWeb.PageLive do
  use SteerWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket = socket
    |> add_channels()

    {:ok, socket}
  end

  defp add_channels(socket) do
    channels = Steer.Channel.get_all(order_by: :local_balance)

    socket
    |> assign(:channels, channels)
  end

  defp add_forwarding_history(socket) do
    forwards = LndClient.get_forwarding_history()

    socket
    |> assign(:forwards, forwards)
  end
end
