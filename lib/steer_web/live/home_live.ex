defmodule SteerWeb.HomeLive do
  use SteerWeb, :live_view
  require Logger

  alias Steer.Lnd.Subscriptions

  @htlc_pubsub_topic inspect(Subscriptions.Htlc)
  @htlc_pubsub_settle_message :settle
  @htlc_pubsub_forward :forward
  @htlc_pubsub_forward_fail :forward_fail
  @htlc_pubsub_link_fail :link_fail

  @invoice_pubsub_topic inspect(Subscriptions.Invoice)
  @invoice_pubsub_created_message :created_message
  @invoice_pubsub_paid_message :paid_message

  @channel_pubsub_topic inspect(Subscriptions.Channel)
  @channel_pubsub_open_message :open_message
  @channel_pubsub_closed_message :closed_message
  @channel_pubsub_active_message :active_message
  @channel_pubsub_inactive_message :inactive_message

  @impl true
  @spec mount(any, any, Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def mount(_params, _session, socket) do
    node = Steer.Repo.get_local_node()

    {:ok,
     socket
     |> assign(page_title: node.alias || "")
     |> get_channels()
     |> subscribe_to_events()}
  end

  defp get_channels(socket) do
    socket
    |> assign(:channels, Steer.Lightning.get_all_channels())
  end

  defp subscribe_to_events(socket) do
    if connected?(socket) do
      Subscriptions.Htlc.subscribe()
      Subscriptions.Invoice.subscribe()
      Subscriptions.Channel.subscribe()
    end

    socket
  end

  @impl true
  def handle_info({@htlc_pubsub_topic, @htlc_pubsub_settle_message, _payload}, socket) do
    write_in_blue("HTLC settle event received")

    {:noreply,
     socket
     |> get_channels
     |> put_flash(:info, "Some HTLC settle event happened")}
  end

  @impl true
  def handle_info({@htlc_pubsub_topic, @htlc_pubsub_forward, _payload}, socket) do
    {:noreply,
     socket
     |> put_flash(
       :info,
       "Forward attempt..."
     )}
  end

  @impl true
  def handle_info({@htlc_pubsub_topic, @htlc_pubsub_forward_fail, payload}, socket) do
    channel_in_alias =
      payload.channel_in_id
      |> Steer.Repo.get_channel()
      |> Map.get(:alias)

    channel_out_alias =
      payload.channel_out_id
      |> Steer.Repo.get_channel()
      |> Map.get(:alias)

    {:noreply,
     socket
     |> put_flash(
       :info,
       "Forward attempt failed from #{channel_in_alias} to #{channel_out_alias}"
     )}
  end

  @impl true
  def handle_info({@htlc_pubsub_topic, @htlc_pubsub_link_fail, _payload}, socket) do
    write_in_blue("HTLC link fail")

    {:noreply,
     socket
     |> put_flash(
       :info,
       "HTLC link fail"
     )}
  end

  @impl true
  def handle_info({@invoice_pubsub_topic, @invoice_pubsub_created_message, _payload}, socket) do
    write_in_yellow("New invoice created")

    # nothing to be done, except maybe inform the user

    {:noreply, socket}
  end

  @impl true
  def handle_info({@invoice_pubsub_topic, @invoice_pubsub_paid_message, _payload}, socket) do
    write_in_yellow("New paid invoice received")
    write_in_yellow(".... updating channels ....")

    channels = Steer.Lightning.get_all_channels()

    {:noreply,
     socket
     |> assign(:channels, channels)
     |> put_flash(:info, "New forward received")}
  end

  @impl true
  def handle_info({@channel_pubsub_topic, @channel_pubsub_open_message, channel}, socket) do
    write_in_green("New channel opened with #{channel.alias}")
    write_in_green(".... NOT updating channels until active ....")

    ### would be nice to refresh the graph at that point, but it seems
    ### a channel refresh poses a problem before the channel becomes active
    ### so we wait at that point...

    {:noreply, socket}
  end

  @impl true
  def handle_info({@channel_pubsub_topic, @channel_pubsub_closed_message, _channel}, socket) do
    write_in_green("A channel has been closed")
    write_in_green(".... updating channels ....")

    channels = Steer.Lightning.get_all_channels()

    {:noreply,
     socket
     |> assign(:channels, channels)
     |> put_flash(:info, "A channel has been closed")}
  end

  @impl true
  def handle_info({@channel_pubsub_topic, @channel_pubsub_active_message, channel}, socket) do
    {:noreply,
     socket
     |> assign(:channels, Steer.Lightning.get_all_channels())
     |> put_flash(:info, "#{channel.alias} became active")}
  end

  @impl true
  def handle_info({@channel_pubsub_topic, @channel_pubsub_inactive_message, channel}, socket) do
    socket =
      socket
      |> assign(:channels, Steer.Lightning.get_all_channels())
      |> put_flash(:info, "#{channel.alias} became inactive")

    {:noreply, socket}
  end

  @impl true
  def handle_info(event, socket) do
    write_in_red("Unknown event received")

    IO.inspect(event)

    {:noreply, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, %{"id" => id_string}) do
    {id, _} = Integer.parse(id_string)

    channel =
      socket.assigns.channels
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

  defp write_in_blue(message) do
    Logger.info(IO.ANSI.blue_background() <> IO.ANSI.black() <> message <> IO.ANSI.reset())
  end

  defp write_in_yellow(message) do
    Logger.info(IO.ANSI.yellow_background() <> IO.ANSI.black() <> message <> IO.ANSI.reset())
  end

  defp write_in_red(message) do
    Logger.info(IO.ANSI.red_background() <> IO.ANSI.black() <> message <> IO.ANSI.reset())
  end

  defp write_in_green(message) do
    Logger.info(IO.ANSI.green_background() <> IO.ANSI.black() <> message <> IO.ANSI.reset())
  end
end
