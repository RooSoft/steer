defmodule Steer.HtlcSubscription do
  use GenServer
  require Logger

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
    Logger.info "--------- got a SETTLE event"
    Logger.info "-------- broadcasting"

    lnd_htlc_event
    |> extract_htlc_event_map(:settle)
    |> Steer.Lightning.insert_htlc_event

    {:noreply, state}
  end

  def handle_info(%Routerrpc.HtlcEvent{ event: {:forward_event, forward_event } } = lnd_htlc_event, state) do
    Logger.info "NEW HTLC: forward event"

    htlc_event = lnd_htlc_event
    |> extract_htlc_event_map(:forward)
    |> Steer.Lightning.insert_htlc_event

    forward_event
    |> extract_forward_event_map()
    |> Map.put(:htlc_event_id, htlc_event.id)
    |> Steer.Lightning.insert_htlc_forward

    {:noreply, state}
  end

  def handle_info(%Routerrpc.HtlcEvent{ event: {:forward_fail_event, _ } } = htlc_event, state) do
    Logger.info "NEW HTLC: forward fail event"

    IO.inspect htlc_event

    {:noreply, state}
  end

  def handle_info(%Routerrpc.HtlcEvent{} = htlc_event, state) do
    Logger.info "NEW HTLC of unknown type"

    IO.inspect htlc_event

    {:noreply, state}
  end

  def handle_info(event, state) do
    Logger.info "--------- got an unknown event"
    IO.inspect event

    {:noreply, state}
  end

  defp extract_htlc_event_map htlc_event, type do
    in_channel = Steer.Lightning.get_channel(lnd_id: htlc_event.incoming_channel_id)
    out_channel = Steer.Lightning.get_channel(lnd_id: htlc_event.outgoing_channel_id)
    time = DateTime.from_unix!(htlc_event.timestamp_ns, :nanosecond)

    %{
      type: type,
      channel_in_id: in_channel.id,
      channel_out_id: out_channel.id,
      htlc_in_id: htlc_event.incoming_htlc_id,
      htlc_out_id: htlc_event.outgoing_htlc_id,
      time: DateTime.to_naive(time),
      timestamp_ns: htlc_event.timestamp_ns
    }
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
end
