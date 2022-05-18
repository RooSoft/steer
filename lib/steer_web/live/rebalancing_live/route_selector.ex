defmodule SteerWeb.RebalancingLive.RouteSelector do
  use Phoenix.LiveComponent

  def render(assigns) do
    routes = get_routes(10, assigns.high_liquidity_channel, assigns.low_liquidity_channel)

    ~H"""
    <div>
      <div class="rebalancing-route-selector-header">
        Select a route
      </div>

      <div>
        <%= if Enum.count(routes) == 0 do %>
          <em>no routes</em>
        <% end %>
        <%= for route <- routes do %>
          <%= live_component SteerWeb.RebalancingLive.Route,
            id: "route_#{route.index}",
            starting_channel_id: @high_liquidity_channel.lnd_id,
            pub_keys: route.pub_keys %>
        <% end %>
      </div>
    </div>
    """
  end

  defp get_routes(_route_count, _high_liquidity_channel, _low_liquidity_channel) do
    # Steer.GraphRepo.get_cheapest_routes(
    #   route_count,
    #   high_liquidity_channel.node_pub_key,
    #   low_liquidity_channel.node_pub_key
    # )

    []
  end
end
