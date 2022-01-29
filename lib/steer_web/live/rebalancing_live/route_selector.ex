defmodule SteerWeb.RebalancingLive.RouteSelector do
  use Phoenix.LiveComponent

  def render(assigns) do
    routes = get_routes(10, assigns.high_liquidity_channel, assigns.low_liquidity_channel)

    IO.inspect(assigns.high_liquidity_channel)

    ~H"""
    <div>
      <div class="rebalancing-route-selector-header">
        Select a route
      </div>

      <div>
        <%= for route <- routes do %>
          <pre>
            AMOUNT=10000
            MAX_FEE=100
            OUTGOING_CHAN_ID=<%= assigns.high_liquidity_channel.lnd_id %>
            declare pub_keys=(
              <%= for pub_key <- route.pub_keys do %>
              <%= pub_key %>
              <% end %>
              037b6d303c95b4faf2f62a214cc32c78aa0ded8ab5bd7a11aaa4883bbe292a4764
            )
            ----------------
          </pre>
        <% end %>
      </div>
    </div>
    """
  end

  defp get_routes(route_count, high_liquidity_channel, low_liquidity_channel) do
    Steer.GraphRepo.get_cheapest_routes(
      route_count,
      high_liquidity_channel.node_pub_key,
      low_liquidity_channel.node_pub_key
    )
  end
end
