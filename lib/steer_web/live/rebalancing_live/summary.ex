defmodule SteerWeb.RebalancingLive.Summary do
  use Phoenix.Component

  def summary(assigns) do
    ~H"""
    <div class="rebalancing-summary-header">
      What's going to happen...
    </div>

    <div>
      Will rebalance from
      <em><%= maybe_show_alias assigns.high_liquidity_channel%></em>
      to
      <em><%= maybe_show_alias assigns.low_liquidity_channel%></em>
    </div>
    """
  end

  def maybe_show_alias(nil) do
    ""
  end

  def maybe_show_alias(%{alias: channnel_alias}) do
    channnel_alias
  end
end
