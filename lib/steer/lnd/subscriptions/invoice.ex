defmodule Steer.Lnd.Subscriptions.Invoice do
  use GenServer
  require Logger

  @pubsub %{
    topic: inspect(__MODULE__),
    created_message: :created_message,
    paid_message: :paid_message
  }

  def start() do
    {:ok, subscription} = GenServer.start(__MODULE__, nil, name: __MODULE__)

    Process.monitor(subscription)
  end

  def stop(reason \\ :normal, timeout \\ :infinity) do
    GenServer.stop(__MODULE__, reason, timeout)
  end

  def init(_) do
    LndClient.subscribe_invoices(%{pid: self()})

    {:ok, nil}
  end

  def handle_info(%Lnrpc.Invoice{state: :SETTLED} = invoice, state) do
    Steer.Lightning.sync()
    Steer.Lightning.update_cache()

    invoice
    |> broadcast(@pubsub.paid_message)

    Logger.info("#{invoice.amt_paid} sats has been settled")

    {:noreply, state}
  end

  def handle_info(%Lnrpc.Invoice{state: :OPEN} = invoice, state) do
    invoice
    |> broadcast(@pubsub.created_message)

    {:noreply, state}
  end

  def handle_info({:DOWN, _ref, :process, _subscription, reason}, state) do
    Logger.error("Invoice subscription is DOWN and shouldn't be")
    IO.inspect(reason)
    Logger.info("Restarting invoice subscription")

    start()

    {:noreply, state}
  end

  def handle_info(_event, state) do
    write_in_yellow("--------- got an unknown invoice event")

    {:noreply, state}
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Steer.PubSub, @pubsub.topic)
  end

  defp broadcast(payload, message) do
    Phoenix.PubSub.broadcast(Steer.PubSub, @pubsub.topic, {@pubsub.topic, message, payload})

    payload
  end

  defp write_in_yellow(message) do
    Logger.info(IO.ANSI.yellow_background() <> IO.ANSI.black() <> message <> IO.ANSI.reset())
  end
end
