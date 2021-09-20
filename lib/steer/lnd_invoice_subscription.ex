defmodule Steer.LndInvoiceSubscription do
  use GenServer
  require Logger

  alias SteerWeb.Endpoint

  @invoice_topic "invoice"
  @created_message "created"
  @paid_message "paid"

  def start() do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def stop(reason \\ :normal, timeout \\ :infinity) do
    GenServer.stop(__MODULE__, reason, timeout)
  end

  def init(_) do
    LndClient.subscribe_invoices(%{pid: self()})

    { :ok, nil }
  end

  def handle_info(%Lnrpc.Invoice{state: :SETTLED} = invoice, state) do
    invoice
    |> broadcast(@invoice_topic, @paid_message)

    {:noreply, state}
  end

  def handle_info(%Lnrpc.Invoice{state: :OPEN} = invoice, state) do
    invoice
    |> broadcast(@invoice_topic, @created_message)

    {:noreply, state}
  end

  def handle_info(_event, state) do
    write_in_yellow "--------- got an unknown invoice event"

    {:noreply, state}
  end

  defp write_in_yellow message do
    Logger.info(IO.ANSI.yellow_background() <> IO.ANSI.black() <> message <> IO.ANSI.reset())
  end

  defp broadcast channel, topic, message do
    Endpoint.broadcast(topic, message, channel)

    channel
  end
end
