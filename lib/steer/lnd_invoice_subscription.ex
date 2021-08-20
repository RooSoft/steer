defmodule Steer.LndInvoiceSubscription do
  use GenServer
  require Logger

  alias SteerWeb.Endpoint

  @invoice_topic "invoice"
  @created_message "created"
  @paid_message "paid"

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def stop(reason \\ :normal, timeout \\ :infinity) do
    GenServer.stop(__MODULE__, reason, timeout)
  end

  def init(_) do
    LndClient.subscribe_invoices(%{pid: self()})

    { :ok, nil }
  end

  def handle_info(%Lnrpc.Invoice{state: :SETTLED} = invoice, state) do
    write_in_yellow "Got a SETTLED invoice vent"

    Endpoint.broadcast(@invoice_topic, @paid_message, invoice)

    {:noreply, state}
  end

  def handle_info(%Lnrpc.Invoice{state: :OPEN} = invoice, state) do
    write_in_yellow "Got a OPEN invoice vent"

    Endpoint.broadcast(@invoice_topic, @created_message, invoice)

    {:noreply, state}
  end

  def handle_info(_event, state) do
    write_in_yellow "--------- got an unknown invoice event"

    {:noreply, state}
  end

  defp write_in_yellow message do
    Logger.info(IO.ANSI.yellow_background() <> IO.ANSI.black() <> message <> IO.ANSI.reset())
  end
end
