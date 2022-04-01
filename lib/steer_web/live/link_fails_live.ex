defmodule SteerWeb.LinkFailsLive do
  use SteerWeb, :live_view
  require Logger

  alias Steer.Lnd.Subscriptions
  alias Steer.Lightning.Models.HtlcEvent

  @htlc_pubsub_topic inspect(Subscriptions.Htlc)
  @htlc_pubsub_link_fail_message :link_fail

  @impl true
  @spec mount(any, any, Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> load
     |> subscribe_to_events}
  end

  @impl true
  def handle_info({@htlc_pubsub_topic, @htlc_pubsub_link_fail_message, _payload}, socket) do
    {:noreply,
     socket
     |> load
     |> put_flash(:info, "New Link Fail")}
  end

  @impl true
  def handle_info({@htlc_pubsub_topic, _, _payload}, socket) do
    # ignore what's not a link fail

    {:noreply, socket}
  end

  defp load(socket) do
    socket
    |> assign_link_fails
    |> format_channels
    |> format_amounts
  end

  defp subscribe_to_events(socket) do
    if connected?(socket) do
      Subscriptions.Htlc.subscribe()
    end

    socket
  end

  defp assign_link_fails(socket) do
    socket
    |> assign(:link_fails, Steer.Lightning.get_link_fails())
  end

  defp format_channels(%{assigns: %{link_fails: link_fails}} = socket) do
    new_link_fails =
      link_fails
      |> Enum.map(&format_local_node/1)

    socket
    |> assign(:link_fails, new_link_fails)
  end

  defp format_local_node(%{channel_in_id: nil} = link_fails) do
    link_fails
    |> Map.put(:channel_in, "Me")
  end

  defp format_local_node(link_fails) do
    link_fails
  end

  defp format_amounts(%{assigns: %{link_fails: link_fails}} = socket) do
    new_link_fails =
      link_fails
      |> Enum.map(&format_amount/1)

    socket
    |> assign(:link_fails, new_link_fails)
  end

  defp format_amount(link_fail) do
    amount_in_sats = link_fail.amount_in / 1000
    amount_out_sats = link_fail.amount_out / 1000
    fees = amount_in_sats - amount_out_sats

    link_fail
    |> Map.put(
      :formatted_amount_in,
      Number.SI.number_to_si(amount_in_sats, unit: "", precision: 0)
    )
    |> Map.put(
      :formatted_amount_out,
      Number.SI.number_to_si(amount_out_sats, unit: "", precision: 0)
    )
    |> Map.put(
      :formatted_fees,
      Number.SI.number_to_si(fees, unit: "", precision: 0)
    )
  end
end
