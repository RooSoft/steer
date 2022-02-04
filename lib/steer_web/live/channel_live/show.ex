defmodule SteerWeb.ChannelLive.Show do
  use SteerWeb, :live_view

  alias Steer.Lnd.Subscriptions
  alias SteerWeb.Endpoint
  alias SteerWeb.ChannelLive.ForwardsComponent

  import SteerWeb.Components.ShortPubKey

  @htlc_pubsub_topic inspect(Subscriptions.Htlc)
  @htlc_pubsub_settle_message :settle

  @channel_topic "channel"
  # @open_message "open"
  # @closed_message "closed"
  @active_message "active"
  @inactive_message "inactive"

  import SteerWeb.Components.NodeStatusIndicatorComponent
  import SteerWeb.Components.ExternalLinks

  @impl true
  def handle_params(%{"id" => channel_id_string}, _, socket) do
    {channel_id, _} = Integer.parse(channel_id_string)

    {:noreply,
     socket
     |> update_socket(channel_id)
     |> subscribe_to_events()}
  end

  @impl true
  def handle_info({@htlc_pubsub_topic, @htlc_pubsub_settle_message, _htlc_event}, socket) do
    {:noreply,
     socket
     |> update_socket
     |> put_flash(:info, "Some HTLC settle event happened")}
  end

  @impl true
  def handle_info({@htlc_pubsub_topic, _message, _htlc_event}, socket) do
    IO.puts("-----------GOT A HTLC-------")
    {:noreply, socket}
  end

  @impl true
  def handle_info(%{topic: @channel_topic, event: @active_message, payload: channel}, socket) do
    {:noreply,
     socket
     |> update_socket
     |> put_flash(:info, "#{channel.alias} became active")}
  end

  @impl true
  def handle_info(%{topic: @channel_topic, event: @inactive_message, payload: channel}, socket) do
    socket =
      socket
      |> update_socket
      |> put_flash(:info, "#{channel.alias} became inactive")

    {:noreply, socket}
  end

  @impl true
  def handle_info(%{topic: @channel_topic, event: _, payload: _channel}, socket) do
    # ingnore all other events

    {:noreply, socket}
  end

  defp update_socket(socket) do
    socket
    |> update_socket(socket.assigns.channel.id)
  end

  defp update_socket(socket, channel_id) do
    socket
    |> assign(:channel, Steer.Lightning.get_channel(id: channel_id))
    |> assign(:forwards, Steer.Lightning.get_channel_forwards(%{channel_id: channel_id}))
  end

  defp subscribe_to_events(socket) do
    if connected?(socket) do
      Subscriptions.Htlc.subscribe()
      Endpoint.subscribe(@channel_topic)
    end

    socket
  end
end
