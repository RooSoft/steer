defmodule SteerWeb.ChannelLive.Show do
  use SteerWeb, :live_view

  alias Steer.Lnd.Subscriptions
  alias SteerWeb.ChannelLive.ForwardsComponent

  import SteerWeb.Components.ShortPubKey

  @htlc_pubsub_topic inspect(Subscriptions.Htlc)
  @htlc_pubsub_settle_message :settle

  @channel_pubsub_topic inspect(Subscriptions.Channel)
  # @channel_pubsub_open_message :open_message
  # @channel_pubsub_closed_message :closed_message
  @channel_pubsub_active_message :active_message
  @channel_pubsub_inactive_message :inactive_message

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
  def handle_info({@channel_pubsub_topic, @channel_pubsub_active_message, channel}, socket) do
    {:noreply,
     socket
     |> update_socket
     |> put_flash(:info, "#{channel.alias} became active")}
  end

  @impl true
  def handle_info({@channel_pubsub_topic, @channel_pubsub_inactive_message, channel}, socket) do
    socket =
      socket
      |> update_socket
      |> put_flash(:info, "#{channel.alias} became inactive")

    {:noreply, socket}
  end

  @impl true
  def handle_info({@channel_pubsub_topic, _message, _payload}, socket) do
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
      Subscriptions.Channel.subscribe()
    end

    socket
  end
end
