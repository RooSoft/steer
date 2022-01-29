defmodule SteerWeb.RebalancingLive.Summary do
  use Phoenix.Component

  alias Steer.Formatting.Sats

  def summary(assigns) do
    ~H"""
    <div class="rebalancing-summary-header">
      What's going to happen...
    </div>

    <div class="rebalancing-summary-paragraph">
      Trying to rebalance from
      <em><%= maybe_show_alias assigns.high_liquidity_channel%></em>
      to
      <em><%= maybe_show_alias assigns.low_liquidity_channel%></em>
    </div>

    <div class="rebalancing-summary-paragraph">
      <div>
        from: <%= channel_stats assigns.high_liquidity_channel %>
      </div>
      <div>
        to: <%= channel_stats assigns.low_liquidity_channel %>
      </div>
    </div>
    """
  end

  def maybe_show_alias(nil) do
    ""
  end

  def maybe_show_alias(%{alias: node_alias}) do
    node_alias
  end

  def channel_stats(nil) do
    ""
  end

  def channel_stats(%{
        alias: node_alias,
        node_pub_key: _node_pub_key,
        local_balance: local_balance,
        formatted_balance_percent: formatted_balance_percent
      }) do
    "#{node_alias} #{Sats.to_human(local_balance)} #{formatted_balance_percent}%"
  end
end
