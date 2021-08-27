defmodule SteerWeb.AttemptsLive do
  use SteerWeb, :live_view
  require Logger

  @impl true
  @spec mount(any, any, Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def mount(_params, _session, socket) do
    {:ok,
      socket
      |> assign_attempts
      |> format_channels
      |> format_statuses
    }
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
end
