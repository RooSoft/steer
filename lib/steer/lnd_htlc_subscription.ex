defmodule Steer.HtlcSubscription do
  use GenServer

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
    IO.puts "--------- got a SETTLE event"
    IO.puts "-------- broadcasting"

    Endpoint.broadcast(@htlc_topic, @new_message, htlc)

    {:noreply, state}
  end

  def handle_info(%Routerrpc.HtlcEvent{ event: {:forward_event, _forward_event } } = htlc, state) do
    IO.puts "NEW HTLC: forward event"

    IO.inspect htlc

    {:noreply, state}
  end

  def handle_info(%Routerrpc.HtlcEvent{ event: {:forward_fail_event, _ } } = htlc_event, state) do
    IO.puts "NEW HTLC: forward fail event"

    IO.inspect htlc_event

    {:noreply, state}
  end

  def handle_info(%Routerrpc.HtlcEvent{} = htlc_event, state) do
    IO.puts "NEW HTLC of unknown type"

    IO.inspect htlc_event

    {:noreply, state}
  end

  def handle_info(event, state) do
    IO.puts "--------- got an unknown event"
    IO.inspect event

    {:noreply, state}
  end
end
