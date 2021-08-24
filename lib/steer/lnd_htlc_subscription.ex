defmodule Steer.HtlcSubscription do
  use GenServer
  require Logger

  alias SteerWeb.Endpoint

  @htlc_topic "htlc"
  @new_message "new"

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

  def handle_info(%Routerrpc.HtlcEvent{event: {:settle_event, _}} = htlc, state) do
    Logger.info "--------- got a SETTLE event"
    Logger.info "-------- broadcasting"

    Endpoint.broadcast(@htlc_topic, @new_message, htlc)

    {:noreply, state}
  end

  def handle_info(%Routerrpc.HtlcEvent{ event: {:forward_event, _forward_event } } = htlc_event, state) do
    Logger.info "NEW HTLC: forward event"

    IO.inspect htlc_event

    in_channel = Steer.Lightning.get_channel(lnd_id: htlc_event.incoming_channel_id)
    out_channel = Steer.Lightning.get_channel(lnd_id: htlc_event.outgoing_channel_id)
    time = DateTime.from_unix!(htlc_event.timestamp_ns, :nanosecond)

    Steer.Lightning.insert_htlc_event(%{
      type: :forward,
      channel_in_id: in_channel.id,
      channel_out_id: out_channel.id,
      htlc_in_id: htlc_event.incoming_htlc_id,
      htlc_out_id: htlc_event.outgoing_htlc_id,
      time: DateTime.to_naive(time),
      timestamp_ns: htlc_event.timestamp_ns
    })

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
end
