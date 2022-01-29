defmodule SteerWeb.RebalancingLive do
  use SteerWeb, :live_view
  require Logger

  alias Steer.Actions.Rebalancing

  import SteerWeb.RebalancingLive.Summary

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> get_channels
     |> add_low_liquidity_channels_list
     |> add_high_liquidity_channels_list
     |> assign_initial_rebalancing
     |> assign_initial_step
     |> assign_parameters}
  end

  @impl true
  def handle_info({:high_liquidity_channel_selected, channel}, socket) do
    {
      :noreply,
      socket
      |> select_high_liquidty_channel(channel)
      |> go_to_step(2)
    }
  end

  @impl true
  def handle_info({:low_liquidity_channel_selected, channel}, socket) do
    {
      :noreply,
      socket
      |> select_low_liquidty_channel(channel)
      |> go_to_step(3)
    }
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

  defp assign_initial_step(socket) do
    socket
    |> go_to_step(1)
  end

  defp assign_initial_rebalancing(socket) do
    socket
    |> assign(:rebalancing, %Rebalancing{})
  end

  defp assign_parameters(socket) do
    socket
    |> assign(:parameters, %{
      high_liquidity_channel: nil,
      low_liquidity_channel: nil
    })
  end

  defp select_high_liquidty_channel(socket, channel) do
    parameters = socket.assigns.parameters |> Map.put(:high_liquidity_channel, channel)

    socket
    |> assign(:parameters, parameters)
  end

  defp select_low_liquidty_channel(socket, channel) do
    parameters = socket.assigns.parameters |> Map.put(:low_liquidity_channel, channel)

    socket
    |> assign(:parameters, parameters)
  end

  defp go_to_step(socket, step) do
    socket
    |> assign(:step, step)
  end
end
