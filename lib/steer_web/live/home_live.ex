defmodule SteerWeb.HomeLive do
  use SteerWeb, :live_view
  require Logger

  alias SteerWeb.Endpoint

  @htlc_event_topic "htlc_event"
#  @forward_message "forward"
#  @forward_fail_message "forward_fail"
  @settle_message "settle"
#  @link_fail_message "link_fail"

  @invoice_topic "invoice"
  @created_message "created"
  @paid_message "paid"

  @channel_topic "channel"
  @open_message "open"
  @closed_message "closed"
  @active_message "active"
  @inactive_message "inactive"

  @impl true
  @spec mount(any, any, Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def mount(_params, _session, socket) do
    {:ok, socket
      |> get_channels()
      |> subscribe_to_events()}
  end

  defp get_channels(socket) do
    socket
    |> assign(:channels, Steer.Lightning.get_all_channels())
  end

  defp subscribe_to_events(socket) do
    if connected?(socket) do
      Endpoint.subscribe(@htlc_event_topic)
      Endpoint.subscribe(@invoice_topic)
      Endpoint.subscribe(@channel_topic)
    end

    socket
  end

  @impl true
  def handle_info(%{
    topic: @htlc_event_topic,
    event: @settle_message,
    payload: _htlc_event
  }, socket) do

    write_in_blue "HTLC settle event received"

    { :noreply, socket
      |> get_channels
      |> put_flash(:info, "Some HTLC settle event happened")}
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

    channels = Steer.Lightning.get_all_channels()

    { :noreply, socket
      |> assign(:channels, channels)
      |> put_flash(:info, "New forward received")}
  end

  @impl true
  def handle_info(%{ topic: @channel_topic, event: @open_message, payload: channel }, socket) do
    write_in_green "New channel opened with #{channel.alias}"
    write_in_green ".... NOT updating channels until active ...."

    ### would be nice to refresh the graph at that point, but it seems
    ### a channel refresh poses a problem before the channel becomes active
    ### so we wait at that point...

    { :noreply, socket }
  end

  @impl true
  def handle_info(%{ topic: @channel_topic, event: @closed_message }, socket) do
    write_in_green "A channel has been closed"
    write_in_green ".... updating channels ...."

    channels = Steer.Lightning.get_all_channels()

    { :noreply, socket
      |> assign(:channels, channels)
      |> put_flash(:info, "A channel has been closed")}
  end

  @impl true
  def handle_info(%{ topic: @channel_topic, event: @active_message, payload: channel }, socket) do
    { :noreply, socket
      |> assign(:channels, Steer.Lightning.get_all_channels())
      |> put_flash(:info, "#{channel.alias} became active")}
  end

  @impl true
  def handle_info(%{ topic: @channel_topic, event: @inactive_message, payload: channel }, socket) do
    socket = socket
      |> assign(:channels, Steer.Lightning.get_all_channels())
      |> put_flash(:info, "#{channel.alias} became inactive")

    { :noreply, socket }
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

  defp write_in_blue message do
    Logger.info(IO.ANSI.blue_background() <> IO.ANSI.black() <> message <> IO.ANSI.reset())
  end

  defp write_in_yellow message do
    Logger.info(IO.ANSI.yellow_background() <> IO.ANSI.black() <> message <> IO.ANSI.reset())
  end

  defp write_in_red message do
    Logger.info(IO.ANSI.red_background() <> IO.ANSI.black() <> message <> IO.ANSI.reset())
  end

  defp write_in_green message do
    Logger.info(IO.ANSI.green_background() <> IO.ANSI.black() <> message <> IO.ANSI.reset())
  end
end
