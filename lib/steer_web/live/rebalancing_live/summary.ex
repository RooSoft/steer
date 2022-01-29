defmodule SteerWeb.RebalancingLive.Summary do
  use Phoenix.Component

  def summary(assigns) do
    ~H"""
    <span class="rebalancing-summary-header">
      What's going to happen...
    </span>

    <div>
      Will rebalance from
      <%= if assigns.high_liquidity_channel != nil, do: assigns.high_liquidity_channel.alias, else: "" %>
      to
      <%= if assigns.low_liquidity_channel != nil, do: assigns.low_liquidity_channel.alias, else: "" %>
    </div>
    """
  end
end
