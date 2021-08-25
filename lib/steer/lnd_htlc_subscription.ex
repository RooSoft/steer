defmodule Steer.HtlcSubscription do
  use GenServer
  require Logger

  alias SteerWeb.Endpoint

  @htlc_event_topic "htlc_event"
  @forward_message "forward"
  @forward_fail_message "forward_fail"
  @settle_message "settle"
  @link_fail_message "link_fail"

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def stop(reason \\ :normal, timeout \\ :infinity) do
    GenServer.stop(__MODULE__, reason, timeout)
  end

  def init(_) do
    LndClient.subscribe_htlc_events(%{pid: self()})

    { :ok, nil }
  end

  def handle_info(%Routerrpc.HtlcEvent{event: {:settle_event, _}} = lnd_htlc_event, state) do
    htlc_event = lnd_htlc_event
    |> extract_htlc_event_map(:settle)
    |> Steer.Lightning.insert_htlc_event
    |> broadcast(@htlc_event_topic, @settle_message)

    Logger.info "HTLC settle event \##{htlc_event.id}"

    {:noreply, state}
  end

  def handle_info(%Routerrpc.HtlcEvent{ event: {:forward_event, lnd_forward_event } } = lnd_htlc_event, state) do
    htlc_event = lnd_htlc_event
    |> extract_htlc_event_map(:forward)
    |> Steer.Lightning.insert_htlc_event

    forward_event = lnd_forward_event
    |> extract_forward_event_map()
    |> Map.put(:htlc_event_id, htlc_event.id)
    |> Steer.Lightning.insert_htlc_forward
    |> broadcast(@htlc_event_topic, @forward_message)

    Logger.info "HTLC forward event \##{forward_event.id}"

    {:noreply, state}
  end

  def handle_info(%Routerrpc.HtlcEvent{ event: {:forward_fail_event, _ } } = lnd_htlc_event, state) do
    htlc_event = lnd_htlc_event
    |> extract_htlc_event_map(:forward_fail)
    |> Steer.Lightning.insert_htlc_event
    |> broadcast(@htlc_event_topic, @forward_fail_message)

    Logger.info "HTLC forward fail event \##{htlc_event.id}"

    {:noreply, state}
  end

  def handle_info(%Routerrpc.HtlcEvent{ event: {:link_fail_event, lnd_link_fail_event } } = lnd_htlc_event, state) do
    htlc_event = lnd_htlc_event
    |> extract_htlc_event_map(:link_fail)
    |> Steer.Lightning.insert_htlc_event

    link_fail_event = lnd_link_fail_event
    |> extract_link_fail_event_map()
    |> Map.put(:htlc_event_id, htlc_event.id)
    |> Steer.Lightning.insert_htlc_link_fail()
    |> broadcast(@htlc_event_topic, @link_fail_message)

    Logger.info "HTLC link fail event \##{link_fail_event.id}"

    {:noreply, state}
  end

  def handle_info(%Routerrpc.HtlcEvent{} = htlc_event, state) do
    Logger.info "HTLC of unknown type"

    IO.inspect htlc_event

    {:noreply, state}
  end

  def handle_info(event, state) do
    Logger.info "--------- got an unknown event"
    IO.inspect event

    {:noreply, state}
  end

  defp extract_htlc_event_map htlc_event, type do
    in_channel_id = get_channel_id(htlc_event.incoming_channel_id)
    out_channel_id = get_channel_id(htlc_event.outgoing_channel_id)
    time = DateTime.from_unix!(htlc_event.timestamp_ns, :nanosecond)

    %{
      type: type,
      channel_in_id: in_channel_id,
      channel_out_id: out_channel_id,
      htlc_in_id: htlc_event.incoming_htlc_id,
      htlc_out_id: htlc_event.outgoing_htlc_id,
      time: DateTime.to_naive(time),
      timestamp_ns: htlc_event.timestamp_ns
    }
  end

  defp get_channel_id 0 do
    nil
  end

  defp get_channel_id lnd_id do
    case Steer.Lightning.get_channel(lnd_id: lnd_id) do
      nil -> nil
      channel -> channel.id
    end
  end

  defp extract_forward_event_map %{ info: %Routerrpc.HtlcInfo{
    incoming_amt_msat: incoming_amt_msat,
    outgoing_amt_msat: outgoing_amt_msat,
    incoming_timelock: incoming_timelock,
    outgoing_timelock: outgoing_timelock
  }} do
    %{
      amount_in: incoming_amt_msat,
      amount_out: outgoing_amt_msat,
      timelock_in: incoming_timelock,
      timelock_out: outgoing_timelock
    }
  end

  defp extract_link_fail_event_map %Routerrpc.LinkFailEvent{
    failure_detail: failure_detail,
    failure_string: failure_string,
    wire_failure: wire_failure,
    info: %Routerrpc.HtlcInfo{
      incoming_amt_msat: incoming_amt_msat,
      outgoing_amt_msat: outgoing_amt_msat,
      incoming_timelock: incoming_timelock,
      outgoing_timelock: outgoing_timelock
      }
  } do
    %{
      amount_in: incoming_amt_msat,
      amount_out: outgoing_amt_msat,
      timelock_in: incoming_timelock,
      timelock_out: outgoing_timelock,
      failure_detail: Atom.to_string(failure_detail),
      failure_string: failure_string,
      wire_failure: Atom.to_string(wire_failure)
    }
  end

  defp broadcast htlc_event, topic, message do
    Endpoint.broadcast(topic, message, htlc_event)

    htlc_event
  end
end
