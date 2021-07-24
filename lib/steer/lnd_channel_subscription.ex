defmodule Steer.LndChannelSubscription do
  use GenServer

  alias SteerWeb.Endpoint

  @channel_topic "channel"
  @open_message "open"
  @closed_message "closed"
  @pending_message "pending"
  @active_message "active"
  @inactive_message "inactive"

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def stop(reason \\ :normal, timeout \\ :infinity) do
    GenServer.stop(__MODULE__, reason, timeout)
  end

  def init(_) do
    LndClient.subscribe_channel_event(%{pid: self()})

    { :ok, nil }
  end

  def handle_info(%Lnrpc.ChannelEventUpdate{type: :PENDING_OPEN_CHANNEL} = channel, state) do
    write_in_green "--------- new PENDING channel"

    Endpoint.broadcast(@channel_topic, @pending_message, channel)

    {:noreply, state}
  end

  def handle_info(%Lnrpc.ChannelEventUpdate{type: :OPEN_CHANNEL} = channel, state) do
    write_in_green "--------- new OPEN channel"

    Endpoint.broadcast(@channel_topic, @open_message, channel)

    {:noreply, state}
  end

  def handle_info(%Lnrpc.ChannelEventUpdate{type: :CLOSED_CHANNEL} = channel, state) do
    write_in_green "--------- new CLOSED channel"

    Endpoint.broadcast(@channel_topic, @closed_message, channel)

    {:noreply, state}
  end

  def handle_info(%Lnrpc.ChannelEventUpdate{type: :ACTIVE_CHANNEL} = channel, state) do
    write_in_green "--------- new :ACTIVE_CHANNEL channel"

    Endpoint.broadcast(@channel_topic, @active_message, channel)

    {:noreply, state}
  end

  def handle_info(%Lnrpc.ChannelEventUpdate{type: :INACTIVE_CHANNEL} = channel, state) do
    write_in_green "--------- new :INACTIVE_CHANNEL channel"

    Endpoint.broadcast(@channel_topic, @inactive_message, channel)

    {:noreply, state}
  end

  def handle_info(event, state) do
    IO.puts "--------- got an unknown channel event"
    IO.inspect event

    {:noreply, state}
  end

  defp write_in_green message do
    IO.puts(IO.ANSI.green_background() <> IO.ANSI.black() <> message <> IO.ANSI.reset())
  end
end
