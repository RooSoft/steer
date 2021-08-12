defmodule SteerWeb.HomeLive do
  use SteerWeb, :live_view

  alias SteerWeb.Endpoint

  @htlc_topic "htlc"
  @new_message "new"

  @invoice_topic "invoice"
  @created_message "created"
  @paid_message "paid"

  @channel_topic "channel"
  @open_message "open"
  @pending_message "pending"
  @closed_message "closed"
  @active_message "active"
  @inactive_message "inactive"

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket
      |> add_channels()}
  end

  defp add_channels(socket) do
    if connected?(socket) do
      Endpoint.subscribe(@htlc_topic)
      Endpoint.subscribe(@invoice_topic)
      Endpoint.subscribe(@channel_topic)
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
  def handle_info(%{
    topic: @htlc_topic,
    event: @new_message,
    payload: %Routerrpc.HtlcEvent{
      event_type: event_type
    } }, socket) do

    write_in_blue "New HTLC received: #{event_type}"
    write_in_blue ".... updating channels ...."

    channels = Steer.Lnd.get_all_channels()

    { :noreply, socket
      |> assign(:channels, channels)
      |> put_flash(:info, "New forward received")}
  end

  @impl true
  def handle_info(%{ topic: @invoice_topic, event: @created_message }, socket) do
    write_in_yellow "New invoice created"

    # nothing to be done, except maybe inform the user

    { :noreply, socket }
  end

  @impl true
  def handle_info(%{ topic: @invoice_topic, event: @paid_message }, socket) do
    write_in_yellow "New paid invoice received"
    write_in_yellow ".... updating channels ...."

    channels = Steer.Lnd.get_all_channels()

    { :noreply, socket
      |> assign(:channels, channels)
      |> put_flash(:info, "New forward received")}
  end

  @impl true
  def handle_info(%{ topic: @channel_topic, event: @open_message }, socket) do
    write_in_green "A new channel opened"
    write_in_green ".... NOT updating channels until active ...."

    ### would be nice to refresh the graph at that point, but it seems
    ### a channel refresh poses a problem before the channel becomes active
    ### so we wait at that point...

    { :noreply, socket }
  end

  @impl true
  def handle_info(%{ topic: @channel_topic, event: @pending_message }, socket) do
    write_in_green "A channel is pending..."

    { :noreply, socket }
  end

  @impl true
  def handle_info(%{ topic: @channel_topic, event: @closed_message }, socket) do
    write_in_green "A channel has been closed"
    write_in_green ".... updating channels ...."

    channels = Steer.Lnd.get_all_channels()

    { :noreply, socket
      |> assign(:channels, channels)
      |> put_flash(:info, "A channel has been closed")}
  end

  @impl true
  def handle_info(%{ topic: @channel_topic, event: @active_message, payload: channel }, socket) do
    { :noreply, socket
 #   |> assign(:channels, update_channel(socket.assigns.channels, channel))
    |> put_flash(:info, "#{channel.alias} became active")}
  end

  @impl true
  def handle_info(%{ topic: @channel_topic, event: @inactive_message, payload: channel }, socket) do
    { :noreply, socket
 #     |> assign(:channels, update_channel(socket.assigns.channels, channel))
      |> put_flash(:info, "#{channel.alias} became inactive")}
  end

  @impl true
  def handle_info(event, socket) do
    write_in_red "Unknown event received"

    IO.inspect event

    { :noreply, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, socket
      |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, %{"id" => id_string}) do
    { id, _ } = Integer.parse(id_string)

    channel = socket.assigns.channels
    |> find_channel(id)

    socket
    |> assign(:channel, channel)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:channel, nil)
  end

  defp find_channel(channels, id) do
    channels
    |> Enum.find(fn channel ->
      channel.id == id
    end)
  end

  defp update_channel(channels, channel) do
    channel_point = channel.channel_point

    channels
    |> Enum.map(fn
      %{channel_point: ^channel_point} -> channel
      other -> other
    end)
  end

  defp write_in_blue message do
    IO.puts(IO.ANSI.blue_background() <> IO.ANSI.black() <> message <> IO.ANSI.reset())
  end

  defp write_in_yellow message do
    IO.puts(IO.ANSI.yellow_background() <> IO.ANSI.black() <> message <> IO.ANSI.reset())
  end

  defp write_in_red message do
    IO.puts(IO.ANSI.red_background() <> IO.ANSI.black() <> message <> IO.ANSI.reset())
  end

  defp write_in_green message do
    IO.puts(IO.ANSI.green_background() <> IO.ANSI.black() <> message <> IO.ANSI.reset())
  end
end
