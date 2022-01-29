defmodule SteerWeb.RebalancingLive.Status do
  use Phoenix.Component

  def status(assigns) do
    ~H"""
    <div>
      Will rebalance from
      <%= if assigns.high_liquidity_channel != nil, do: assigns.high_liquidity_channel.alias, else: "" %>
      to
      <%= if assigns.low_liquidity_channel != nil, do: assigns.low_liquidity_channel.alias, else: "" %>
    </div>
    """
  end
end
