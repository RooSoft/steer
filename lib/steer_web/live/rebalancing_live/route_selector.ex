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
        <%= for route <- routes do %>
          <pre>
    <%= get_igniter_config(assigns.high_liquidity_channel.lnd_id, route.pub_keys) %>
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

  defp get_igniter_config(lnd_id, pub_keys) do
    """
    AMOUNT=10000
    MAX_FEE=100
    OUTGOING_CHAN_ID=#{lnd_id}
    declare pub_keys=(
      #{Enum.join(pub_keys, "\n  ")}
      037b6d303c95b4faf2f62a214cc32c78aa0ded8ab5bd7a11aaa4883bbe292a4764
    )
    """
  end
end
