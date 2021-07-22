defmodule SteerWeb.PageLive do
  use SteerWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket = socket
    |> get_channels()
    |> format_balances()
    |> order_channels_by_local_balance()

    {:ok, socket}
  end

  defp get_channels(socket) do
    channels = LndClient.get_channels().channels
    |> Enum.map(fn channel ->
      node_info = LndClient.get_node_info(channel.remote_pubkey)

      channel
      |> Map.put(:alias, node_info.node.alias)
    end)

    socket
    |> assign(:channels, channels)
  end

  defp format_balances(socket) do
    channels = socket.assigns.channels
    |> Enum.map(fn channel ->
      formatted_local_balance = Number.SI.number_to_si(channel.local_balance, unit: "", precision: 1)
      formatted_remote_balance = Number.SI.number_to_si(channel.remote_balance, unit: "", precision: 1)

      channel
      |> Map.put(:formatted_local_balance, formatted_local_balance)
      |> Map.put(:formatted_remote_balance, formatted_remote_balance)
    end)

    socket
    |> assign(:channels, channels)
  end

  defp order_channels_by_local_balance(socket) do
    channels = socket.assigns.channels
    |> Enum.sort(&(&1.local_balance >= &2.local_balance))

    socket
    |> assign(:channels, channels)
  end
end
