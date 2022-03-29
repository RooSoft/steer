defmodule SteerWeb.ChannelLive.Components.Liquidity do
  use Phoenix.Component

  def liquidity(assigns) do
    ~H"""
    <div class="channel-liquidity-details">
      <div>
        <%= @channel.formatted_capacity %>
        <span class="text-xs">sats, </span>
        <%= @channel.formatted_balance_percent %>%
        <span class="text-xs">local</span>
      </div>
      <div>
        <%= @channel.formatted_local_balance %>
        <span class="text-xs">sats local</span>
      </div>
      <div>
        <%= @channel.formatted_remote_balance %>
        <span class="text-xs">sats remote</span>
      </div>
    </div>

    <div class="channel-liquidity-fees">
      <div>pub key1: <%= @lnd_edge.node1_pub %></div>
      <div>base1: <%= @lnd_edge.node1_policy.fee_base_msat / 1000 %> sats</div>
      <div>rate1: <%= @lnd_edge.node1_policy.fee_rate_milli_msat %> PPM</div>

      <div>pub key2: <%= @lnd_edge.node2_pub %></div>
      <div>base2: <%= @lnd_edge.node2_policy.fee_base_msat / 1000 %> sats</div>
      <div>rate2: <%= @lnd_edge.node2_policy.fee_rate_milli_msat %> PPM</div>
    </div>
    """
  end
end
