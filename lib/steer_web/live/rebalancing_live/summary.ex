defmodule SteerWeb.RebalancingLive.Summary do
  use Phoenix.Component

  alias Steer.Formatting.Sats

  def summary(assigns) do
    ~H"""
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

  defp channel_stats(nil) do
    ""
  end

  defp channel_stats(%{
         alias: node_alias,
         node_pub_key: _node_pub_key,
         local_balance: local_balance,
         formatted_balance_percent: formatted_balance_percent
       }) do
    "#{node_alias} #{Sats.to_human(local_balance)} #{formatted_balance_percent}%"
  end
end
