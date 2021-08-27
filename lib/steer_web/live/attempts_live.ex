defmodule SteerWeb.AttemptsLive do
  use SteerWeb, :live_view
  require Logger

  alias SteerWeb.Endpoint

  @htlc_event_topic "htlc_event"

  @impl true
  @spec mount(any, any, Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def mount(_params, _session, socket) do
    {:ok,
      socket
      |> load
      |> subscribe_to_events
    }
  end

  @impl true
  def handle_info(%{
    topic: @htlc_event_topic,
    event: event,
    payload: _htlc_event
  }, socket) do

    { :noreply,
      socket
      |> load
      |> put_flash(:info, "Some HTLC settle event happened: #{event}")}
  end

  defp load(socket) do
    socket
    |> assign_attempts
    |> format_channels
    |> format_statuses
    |> format_amounts
  end

  defp subscribe_to_events(socket) do
    if connected?(socket) do
      Endpoint.subscribe(@htlc_event_topic)
    end

    socket
  end

  defp assign_attempts(socket) do
    socket
    |> assign(:attempts, Steer.Lightning.get_htlc_forwards_with_statuses())
  end

  defp format_channels(%{ assigns: %{ attempts: attempts } } = socket) do
    new_attempts = attempts
    |> Enum.map(&format_local_node/1)

    socket
    |> assign(:attempts, new_attempts)
  end

  defp format_local_node %{ channel_in_id: nil } = attempt do
    attempt
    |> Map.put(:channel_in, "Me")
  end

  defp format_local_node attempt do
    attempt
  end

  defp format_statuses(%{ assigns: %{ attempts: attempts } } = socket) do
    new_attempts = attempts
    |> Enum.map(&format_status/1)

    socket
    |> assign(:attempts, new_attempts)
  end

  defp format_status(%{ fail_id: fail_id } = attempt) when is_number(fail_id) do
    attempt
    |> Map.put(:status, "failed")
  end

  defp format_status(%{ settle_id: settle_id } = attempt) when is_number(settle_id) do
    attempt
    |> Map.put(:status, "settled")
  end

  defp format_status attempt do
    attempt
    |> Map.put(:status, "unknown")
    |> IO.inspect
  end

  defp format_amounts(%{ assigns: %{ attempts: attempts } } = socket) do
    new_attempts = attempts
    |> Enum.map(&format_amount/1)

    socket
    |> assign(:attempts, new_attempts)
  end

  defp format_amount(attempt) do
    amount_in_sats = attempt.amount_in/1000
    amount_out_sats = attempt.amount_out/1000

    attempt
    |> Map.put(
      :formatted_amount_in,
      Number.SI.number_to_si(amount_in_sats, unit: "", precision: 0)
    )
    |> Map.put(
      :formatted_amount_out,
      Number.SI.number_to_si(amount_out_sats, unit: "", precision: 0)
      )
  end
end
