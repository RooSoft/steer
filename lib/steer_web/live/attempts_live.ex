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
    |> IO.inspect
  end

  defp format_local_node attempt do
    attempt
  end
end
