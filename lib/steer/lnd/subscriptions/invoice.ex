defmodule Steer.Lnd.Subscriptions.Invoice do
  use LndClient.InvoiceUpdatesSubscriber

  @pubsub %{
    topic: inspect(__MODULE__),
    created_message: :created_message,
    paid_message: :paid_message
  }

  @impl LndClient.InvoiceUpdatesSubscriber
  def handle_subscription_update(%Lnrpc.Invoice{state: :SETTLED} = invoice) do
    Steer.Lightning.sync()
    Steer.Lightning.update_cache()

    invoice
    |> broadcast(@pubsub.paid_message)

    Logger.info("#{invoice.amt_paid} sats has been settled")
  end

  @impl LndClient.InvoiceUpdatesSubscriber
  def handle_subscription_update(%Lnrpc.Invoice{state: :OPEN} = invoice) do
    invoice
    |> broadcast(@pubsub.created_message)

    Logger.info("#{invoice.value_msat} msats was just created")
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Steer.PubSub, @pubsub.topic)
  end

  defp broadcast(payload, message) do
    Phoenix.PubSub.broadcast(Steer.PubSub, @pubsub.topic, {@pubsub.topic, message, payload})

    payload
  end
end
