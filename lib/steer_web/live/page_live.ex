defmodule SteerWeb.PageLive do
  use SteerWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket = socket
    |> add_channels()

    {:ok, socket}
  end

  defp add_channels(socket) do
    channels = Steer.Lnd.get_all_channels(order_by: :local_balance)

    socket
    |> assign(:channels, channels)
  end
end
