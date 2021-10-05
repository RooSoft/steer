defmodule SteerWeb.AttemptsLive do
  use SteerWeb, :live_view
  require Logger

  alias SteerWeb.Endpoint

  @attempts_per_page 20

  @htlc_event_topic "htlc_event"

  @impl true
  @spec mount(any, any, Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def mount(_params, _session, socket) do
    {:ok,
      socket
      |> init_attempts
      |> load
      |> subscribe_to_events
    }
  end

  @impl true
  def handle_event("load-more", %{"htlc-id" => htlc_id}, socket) do
    Logger.info "load more... from #{htlc_id}"

    {:noreply,
      socket
      |> load(from_forward_htlc_id: htlc_id)}
  end

  @impl true
  def handle_info(%{
    topic: @htlc_event_topic,
    event: event,
    payload: htlc_event
  }, socket) do

    { :noreply,
      socket
      |> prepend_attempt(htlc_event.id)
      |> format_channels
      |> format_statuses
      |> format_amounts
      |> flag_last
      |> put_flash(:info, "Some HTLC settle event happened: #{event}")}
  end

  defp init_attempts(socket) do
    socket
    |> assign(:attempts, [])
  end

  defp prepend_attempt(socket, htlc_id) do
    [attempt] = Steer.Lightning.get_htlc_forwards_with_statuses(
      from_forward_htlc_id: htlc_id, limit: 1
    )

    socket
    |> assign(:attempts, [attempt | socket.assigns.attempts])
  end

  defp load(socket, options \\ []) do
    socket
    |> assign_attempts(options)
    |> format_channels
    |> format_statuses
    |> format_amounts
    |> flag_last
  end

  defp subscribe_to_events(socket) do
    if connected?(socket) do
      Endpoint.subscribe(@htlc_event_topic)
    end

    socket
  end

  defp assign_attempts(socket, options) do
    defaults = %{from_forward_htlc_id: nil, limit: @attempts_per_page, offset: 1}
    options = Enum.into(options, defaults)

    current_attempts = socket.assigns.attempts
    new_attempts = Steer.Lightning.get_htlc_forwards_with_statuses(options)

    socket
    |> assign(:attempts, current_attempts ++ new_attempts)
  end

  defp flag_last socket do
    attempts = socket.assigns.attempts

    number_of_attempts = attempts |> Enum.count

    socket
    |> assign(:attempts,
      Enum.with_index(attempts, 1) |> Enum.map(fn { attempt, index } ->
        attempt |> Map.put(:is_last, index == number_of_attempts)
      end)
    )
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
