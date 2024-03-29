defmodule Steer.Lnd.Subscriptions.Htlc do
  use GenServer
  require Logger

  @pubsub %{
    topic: inspect(__MODULE__),
    forward_message: :forward,
    forward_fail_message: :forward_fail,
    settle_message: :settle,
    link_fail_message: :link_fail
  }

  def start() do
    {:ok, subscription} = GenServer.start_link(__MODULE__, nil, name: __MODULE__)

    Process.monitor(subscription)
  end

  def stop(reason \\ :normal, timeout \\ :infinity) do
    GenServer.stop(__MODULE__, reason, timeout)
  end

  def init(_) do
    Logger.debug("subscribing to HTLCs")
    LndClient.subscribe_htlc_events(%{pid: self()})

    {:ok, nil}
  end

  def handle_info(%Routerrpc.HtlcEvent{event: {:settle_event, _}} = lnd_htlc_event, state) do
    htlc_event =
      lnd_htlc_event
      |> extract_htlc_event_map(:settle)
      |> Steer.Lightning.insert_htlc_event()

    Steer.Sync.Channel.sync()
    Steer.Sync.Forward.sync()

    htlc_event
    |> broadcast(@pubsub.settle_message)

    Logger.info("HTLC settle event \##{htlc_event.id}")

    {:noreply, state}
  end

  def handle_info(
        %Routerrpc.HtlcEvent{event: {:forward_event, lnd_forward_event}} = lnd_htlc_event,
        state
      ) do
    htlc_event =
      lnd_htlc_event
      |> extract_htlc_event_map(:forward)
      |> Steer.Lightning.insert_htlc_event()

    forward_event =
      lnd_forward_event
      |> extract_forward_event_map()
      |> Map.put(:htlc_event_id, htlc_event.id)
      |> Steer.Lightning.insert_htlc_forward()
      |> broadcast(@pubsub.forward_message)

    Logger.debug("HTLC forward event \##{forward_event.id}")

    {:noreply, state}
  end

  def handle_info(%Routerrpc.HtlcEvent{event: {:forward_fail_event, _}} = lnd_htlc_event, state) do
    htlc_event =
      lnd_htlc_event
      |> extract_htlc_event_map(:forward_fail)
      |> Steer.Lightning.insert_htlc_event()
      |> broadcast(@pubsub.forward_fail_message)

    Logger.debug("HTLC forward fail event \##{htlc_event.id}")

    {:noreply, state}
  end

  def handle_info(
        %Routerrpc.HtlcEvent{event: {:link_fail_event, lnd_link_fail_event}} = lnd_htlc_event,
        state
      ) do
    htlc_event =
      lnd_htlc_event
      |> extract_htlc_event_map(:link_fail)
      |> Steer.Lightning.insert_htlc_event()

    link_fail_event =
      lnd_link_fail_event
      |> extract_link_fail_event_map()
      |> Map.put(:htlc_event_id, htlc_event.id)
      |> Steer.Lightning.insert_htlc_link_fail()
      |> broadcast(@pubsub.link_fail_message)

    Logger.info("HTLC link fail event \##{link_fail_event.id}")

    {:noreply, state}
  end

  def handle_info(%Routerrpc.HtlcEvent{} = htlc_event, state) do
    Logger.info("HTLC of unknown type")

    IO.inspect(htlc_event)

    {:noreply, state}
  end

  def handle_info({:DOWN, _ref, :process, _subscription, reason}, state) do
    Logger.error("HTLC subscription is DOWN and shouldn't be")
    IO.inspect(reason)
    Logger.info("Restarting HTLC subscription")

    start()

    {:noreply, state}
  end

  def handle_info(event, state) do
    Logger.info("--------- got an unknown event")
    IO.inspect(event)

    {:noreply, state}
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Steer.PubSub, @pubsub.topic)
  end

  defp broadcast(payload, message) do
    Phoenix.PubSub.broadcast(Steer.PubSub, @pubsub.topic, {@pubsub.topic, message, payload})

    payload
  end

  defp extract_htlc_event_map(htlc_event, type) do
    in_channel_id = get_channel_id(htlc_event.incoming_channel_id)
    out_channel_id = get_channel_id(htlc_event.outgoing_channel_id)

    %{
      type: type,
      channel_in_id: in_channel_id,
      channel_out_id: out_channel_id,
      htlc_in_id: htlc_event.incoming_htlc_id,
      htlc_out_id: htlc_event.outgoing_htlc_id,
      timestamp_ns: htlc_event.timestamp_ns
    }
  end

  defp get_channel_id(0) do
    nil
  end

  defp get_channel_id(lnd_id) do
    case Steer.Lightning.get_channel(lnd_id: lnd_id) do
      nil -> nil
      channel -> channel.id
    end
  end

  defp extract_forward_event_map(%{
         info: %Routerrpc.HtlcInfo{
           incoming_amt_msat: incoming_amt_msat,
           outgoing_amt_msat: outgoing_amt_msat,
           incoming_timelock: incoming_timelock,
           outgoing_timelock: outgoing_timelock
         }
       }) do
    %{
      amount_in: incoming_amt_msat,
      amount_out: outgoing_amt_msat,
      timelock_in: incoming_timelock,
      timelock_out: outgoing_timelock
    }
  end

  defp extract_link_fail_event_map(%Routerrpc.LinkFailEvent{
         failure_detail: failure_detail,
         failure_string: failure_string,
         wire_failure: wire_failure,
         info: %Routerrpc.HtlcInfo{
           incoming_amt_msat: incoming_amt_msat,
           outgoing_amt_msat: outgoing_amt_msat,
           incoming_timelock: incoming_timelock,
           outgoing_timelock: outgoing_timelock
         }
       }) do
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
end
