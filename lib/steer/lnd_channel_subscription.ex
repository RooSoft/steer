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
  #  write_in_green "--------- new PENDING channel"

    Endpoint.broadcast(@channel_topic, @pending_message, channel)

    {:noreply, state}
  end

  def handle_info(%Lnrpc.ChannelEventUpdate{type: :OPEN_CHANNEL} = channel, state) do
  #  write_in_green "--------- new OPEN channel"

    Endpoint.broadcast(@channel_topic, @open_message, channel)

    {:noreply, state}
  end

  def handle_info(%Lnrpc.ChannelEventUpdate{type: :CLOSED_CHANNEL} = channel, state) do
 #   write_in_green "--------- new CLOSED channel"

    Endpoint.broadcast(@channel_topic, @closed_message, channel)

    {:noreply, state}
  end

  def handle_info(%Lnrpc.ChannelEventUpdate{
    type: :ACTIVE_CHANNEL,
    channel: {:active_channel, channel_point_struct }
  }, state) do

    channel_point = convert_channel_point(channel_point_struct)

    Steer.Lightning.get_channel_by_channel_point(channel_point)
    |> Steer.Lightning.update_channel(%{ is_active: true })
    |> write_status_change("active")
    |> broadcast(@channel_topic, @active_message)

    {:noreply, state}
  end

  def handle_info(%Lnrpc.ChannelEventUpdate{
      type: :INACTIVE_CHANNEL,
      channel: {:inactive_channel, channel_point_struct }
    }, state) do

    channel_point = convert_channel_point(channel_point_struct)

    Steer.Lightning.get_channel_by_channel_point(channel_point)
    |> Steer.Lightning.update_channel(%{ is_active: false })
    |> write_status_change("inactive")
    |> broadcast(@channel_topic, @inactive_message)

    {:noreply, state}
  end

  def handle_info(event, state) do
    IO.puts "--------- got an unknown channel event"
    IO.inspect event

    {:noreply, state}
  end

  defp write_status_change channel, status do
    IO.puts(
      IO.ANSI.green_background() <>
      IO.ANSI.black() <>
      "#{channel.alias} became #{status}" <> IO.ANSI.reset()
    )

    channel
  end

  defp broadcast channel, topic, message do
    Endpoint.broadcast(topic, message, channel)

    channel
  end

  defp convert_channel_point(channel_point_struct) do
    { :funding_txid_bytes, funding_txid } = channel_point_struct.funding_txid

    txid = funding_txid
    |> :binary.bin_to_list
    |> Enum.reverse
    |> :binary.list_to_bin
    |> Base.encode16
    |> String.downcase

    "#{txid}:#{channel_point_struct.output_index}"
  end
end
