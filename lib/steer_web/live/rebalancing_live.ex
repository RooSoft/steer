defmodule SteerWeb.RebalancingLive do
  use SteerWeb, :live_view
  require Logger

  alias Steer.Formatting.Sats
  alias Steer.Actions.Rebalancing

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> get_channels
     |> add_low_liquidity_channels_list
     |> add_high_liquidity_channels_list
     |> assign_initial_rebalancing
     |> assign_initial_step
     |> assign_initial_summary
     |> assign_parameters}
  end

  @impl true
  def handle_event(
        "rebalancing-generate-igniter",
        %{"selectedLowId" => selectedLowId, "selectedHighId" => selectedHighId},
        socket
      ) do
    low_liquidity_node = Steer.Lightning.get_channel(id: selectedLowId)
    high_liquidity_node = Steer.Lightning.get_channel(id: selectedHighId)

    IO.puts("---------- will send igniter script ---------")
    IO.inspect(high_liquidity_node)

    IO.puts(
      "low: #{low_liquidity_node.alias} #{low_liquidity_node.node_pub_key} #{Sats.to_human(low_liquidity_node.local_balance)} #{low_liquidity_node.formatted_balance_percent}%"
    )

    IO.puts(
      "high: #{high_liquidity_node.alias} #{high_liquidity_node.node_pub_key} #{Sats.to_human(high_liquidity_node.local_balance)} #{high_liquidity_node.formatted_balance_percent}%"
    )

    print_routes(10, low_liquidity_node, high_liquidity_node)

    IO.puts("---------------------------------------------")

    {:noreply, socket}
  end

  @impl true
  def handle_info({:high_liquidity_channel_selected, channel}, socket) do
    {
      :noreply,
      socket
      |> select_high_liquidty_channel(channel)
      |> prepend_summary("Selected #{channel.alias} as a high liquidity node")
      |> go_to_step(2)
    }
  end

  @impl true
  def handle_info({:low_liquidity_channel_selected, channel}, socket) do
    {
      :noreply,
      socket
      |> select_low_liquidty_channel(channel)
      |> prepend_summary("Selected #{channel.alias} as a low liquidity node")
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

  defp print_routes(route_count, low_liquidity_node, high_liquidity_node) do
    Steer.GraphRepo.get_cheapest_routes(
      route_count,
      high_liquidity_node.node_pub_key,
      low_liquidity_node.node_pub_key
    )
    |> Enum.each(fn route -> print_route(high_liquidity_node.lnd_id, route) end)

    high_liquidity_node.lnd_id
  end

  defp print_route(outgoing_channel, route) do
    IO.puts("AMOUNT=#{10000}")
    IO.puts("MAX_FEE=#{100}")
    IO.puts("OUTGOING_CHAN_ID=#{outgoing_channel}")

    IO.puts("declare pub_keys=(")

    route.pub_keys
    |> Enum.each(&{IO.puts(&1)})

    IO.puts("037b6d303c95b4faf2f62a214cc32c78aa0ded8ab5bd7a11aaa4883bbe292a4764")

    IO.puts(")")

    IO.puts("")
    IO.puts("----------")
    IO.puts("")
  end

  defp assign_initial_step(socket) do
    socket
    |> go_to_step(1)
  end

  defp assign_initial_summary(socket) do
    socket
    |> assign(:summary, [])
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

  defp prepend_summary(%{assigns: %{summary: summary}} = socket, info) do
    socket
    |> assign(:summary, [info | summary])
  end

  defp go_to_step(socket, step) do
    socket
    |> assign(:step, step)
  end
end
