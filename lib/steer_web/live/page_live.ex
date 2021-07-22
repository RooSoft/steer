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

  @impl true
  def handle_event("toggle_forwards", %{"channel-id" => channel_id}, socket) do
    { channel_id, _ } = Integer.parse(channel_id)

    channels = socket.assigns.channels
    |> Enum.map(fn channel ->
      case channel.id do
        ^channel_id ->
          channel |> Map.put(:show_forwards, !channel.show_forwards)
        _ -> channel
      end
    end)

    {:noreply, assign(socket, :channels, channels)}
  end
end
