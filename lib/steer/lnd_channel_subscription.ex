defmodule Steer.LndChannelSubscription do
  use GenServer
  require Logger

  alias SteerWeb.Endpoint

  @channel_topic "channel"
  @open_message "open"
  @closed_message "closed"
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

  def handle_info(%Lnrpc.ChannelEventUpdate{
    type: :PENDING_OPEN_CHANNEL,
    channel: { :pending_open_channel, _channel }
  }, state) do

    IO.puts "--------GOT A PENDING CHANNEL"

    {:noreply, state}
  end

  def handle_info(%Lnrpc.ChannelEventUpdate{
    type: :OPEN_CHANNEL,
    channel: { :open_channel, channel }
  }, state) do
    wait_for_node(channel.remote_pubkey)

    Steer.Lightning.sync

    IO.puts "--------OPEN CHANNEL"

    Steer.Lightning.get_channel(lnd_id: channel.chan_id)
    |> write_status_change("open")
    |> broadcast(@channel_topic, @open_message)

    {:noreply, state}
  end

  def handle_info(%Lnrpc.ChannelEventUpdate{
    type: :CLOSED_CHANNEL,
    channel: {:closed_channel,
      %Lnrpc.ChannelCloseSummary{channel_point: channel_point}
    }
  }, state) do

    channel_point
    |> Steer.Lightning.get_channel_by_channel_point
    |> Steer.Lightning.update_channel(%{ status: :closed })
    |> write_status_change("closed")
    |> broadcast(@channel_topic, @closed_message)

    {:noreply, state}
  end

  def handle_info(%Lnrpc.ChannelEventUpdate{
    type: :ACTIVE_CHANNEL,
    channel: {:active_channel, channel_point_struct }
  }, state) do

    IO.puts "---ACTIVE_CHANNEL-----"
    IO.inspect channel_point_struct

    convert_channel_point(channel_point_struct)
    |> Steer.Lightning.get_channel_by_channel_point
    |> Steer.Lightning.update_channel(%{ status: :active })
    |> write_status_change("active")
    |> broadcast(@channel_topic, @active_message)

    {:noreply, state}
  end

  def handle_info(%Lnrpc.ChannelEventUpdate{
    type: :INACTIVE_CHANNEL,
    channel: {:inactive_channel, channel_point_struct }
  }, state) do

    IO.puts "----INACTIVE_CHANNEL----"
    IO.inspect channel_point_struct

    channel = convert_channel_point(channel_point_struct)
    |> Steer.Lightning.get_channel_by_channel_point

    if (channel != nil) do
      channel
      |> Steer.Lightning.update_channel(%{ status: :inactive })
      |> write_status_change("inactive")
      |> broadcast(@channel_topic, @inactive_message)
    end

    {:noreply, state}
  end

  def handle_info(event, state) do
    Logger.debug "--------- got an unknown channel event"
    IO.inspect event

    {:noreply, state}
  end

  defp write_status_change channel, status do
    Logger.info(
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

  defp write_in_rgb(message, r, g, b) when is_integer(r) and is_integer(g) and is_integer(b) do
    Logger.info(IO.ANSI.color_background(r, g, b) <> IO.ANSI.black() <> message <> IO.ANSI.reset())
  end

  defp wait_for_node remote_pubkey do
    case LndClient.get_node_info(remote_pubkey) do
      { :ok,
        %Lnrpc.NodeInfo{
          node: %Lnrpc.LightningNode{
            last_update: 0
          }
        }
      } ->
        write_in_rgb("node not ready, waiting one second...", 5, 0, 3)
        :timer.sleep(1000)
        wait_for_node(remote_pubkey)

      { :error,
        %GRPC.RPCError{ status: 5 }
      } ->
        write_in_rgb("node not found, waiting one second...", 5, 0, 3)
        :timer.sleep(1000)
        wait_for_node(remote_pubkey)

      node ->
        write_in_rgb("node found!", 5, 0, 3)
        IO.inspect node
        remote_pubkey
    end
  end
end
