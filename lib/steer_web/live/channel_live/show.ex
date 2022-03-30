defmodule SteerWeb.ChannelLive.Show do
  use SteerWeb, :live_view

  alias Steer.Lnd.Subscriptions

  import SteerWeb.Components.ChannelId

  import SteerWeb.ChannelLive.Components.{Forwards, Liquidity, About}

  @htlc_pubsub_topic inspect(Subscriptions.Htlc)
  @htlc_pubsub_settle_message :settle

  @channel_pubsub_topic inspect(Subscriptions.Channel)
  # @channel_pubsub_open_message :open_message
  # @channel_pubsub_closed_message :closed_message
  @channel_pubsub_active_message :active_message
  @channel_pubsub_inactive_message :inactive_message

  @impl true
  def handle_params(%{"lnd_id" => lnd_id}, _, socket) do
    {:noreply,
     socket
     |> update_socket(lnd_id)
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
    |> update_socket(socket.assigns.channel.lnd_id)
  end

  defp update_socket(socket, lnd_id) do
    channel = Steer.Lightning.get_channel(lnd_id: lnd_id)
    {:ok, lnd_edge} = LndClient.get_channel(channel.lnd_id)

    IO.inspect(lnd_edge)

    socket
    |> assign(:channel, channel)
    |> assign(:forwards, Steer.Lightning.get_channel_forwards(%{channel_id: channel.id}))
    |> assign(:lnd_edge, lnd_edge)
  end

  defp subscribe_to_events(socket) do
    if connected?(socket) do
      Subscriptions.Htlc.subscribe()
      Subscriptions.Channel.subscribe()
    end

    socket
  end
end
