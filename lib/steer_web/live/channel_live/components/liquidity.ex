defmodule SteerWeb.ChannelLive.Components.Liquidity do
  use Phoenix.Component

  def liquidity(assigns) do
    channel = assigns.channel

    ~H"""
    <div class="channel-show-details">
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
    """
  end
end
