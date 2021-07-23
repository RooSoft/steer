defmodule SteerWeb.PageLive do
  use SteerWeb, :live_view

  alias SteerWeb.Endpoint

  @htlc_topic "htlc"
  @new_message "new"

  @impl true
  def mount(_params, _session, socket) do
    socket = socket
    |> add_channels()

    {:ok, socket}
  end

  defp add_channels(socket) do
    if connected?(socket) do
      Endpoint.subscribe(@htlc_topic)
    end

    channels = Steer.Lnd.get_all_channels()

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
          if channel.show_forwards do
            IO.puts "collapsing #{channel.alias}"
          else
            IO.puts "expanding #{channel.alias}"
          end

          channel |> Map.put(:show_forwards, !channel.show_forwards)
        _ -> channel
      end
    end)

    {:noreply, assign(socket, :channels, channels)}
  end

  @impl true
  def handle_info(%{ event: @new_message}, socket) do
    write_in_blue "New HTLC received"

    { :noreply, socket}
  end

  @impl true
  def handle_info(_event, socket) do
    write_in_blue "Unknown event received"

    { :noreply, socket}
  end

  defp write_in_blue message do
    IO.puts(IO.ANSI.blue_background() <> IO.ANSI.black() <> message <> IO.ANSI.reset())
  end
end
