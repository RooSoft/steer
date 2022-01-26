defmodule SteerWeb.RebalancingLive do
  use SteerWeb, :live_view
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> get_channels
     |> add_low_liquidity_channels_list
     |> add_high_liquidity_channels_list}
  end

  @impl true
  def handle_event("rebalancing-generate-igniter", data, socket) do
    IO.puts("---------- will send igniter script ---------")
    IO.inspect(data)
    IO.puts("---------------------------------------------")

    {:noreply, socket}
  end

  defp get_channels(socket) do
    socket
    |> assign(:channels, Steer.Lightning.get_all_channels())
  end

  defp add_low_liquidity_channels_list(%{assigns: %{channels: channels}} = socket) do
    low_liquidity_channels =
      channels
      |> Enum.filter(&(&1.balance_percent < 50))
      |> Enum.sort_by(& &1.balance_percent)

    socket
    |> assign(:low_liquidity_channels, low_liquidity_channels)
  end

  defp add_high_liquidity_channels_list(%{assigns: %{channels: channels}} = socket) do
    high_liquidity_channels =
      channels
      |> Enum.filter(&(&1.balance_percent > 50))
      |> Enum.sort_by(&(-&1.balance_percent))

    socket
    |> assign(:high_liquidity_channels, high_liquidity_channels)
  end
end
