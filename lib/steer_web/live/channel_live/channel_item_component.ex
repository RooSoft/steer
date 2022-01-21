defmodule SteerWeb.ChannelLive.ChannelItemComponent do
  use Phoenix.Component

  import SteerWeb.Components.NodeStatusIndicatorComponent
  import SteerWeb.Components.LiquidityMeeter
  import SteerWeb.Components.ShortPubKey

  def channel_item(assigns) do
    %{channel: channel} = assigns

    ~H"""
    <div>

      <div x-data={"{ pubKey: '#{channel.node_pub_key}' }"}
        class="channel-item"
        style={"border-color:#{channel.color}"}>

        <div class="channel-item-id">

          <div class="channel-item-alias">
            <div class="channel-item-node-status-indicator">
              <.node_status_indicator status={channel.status} />
            </div>

            <div phx-click="">
              <%= channel.alias %>
            </div>
          </div>

          <.short_pub_key pub_key={channel.node_pub_key} />

          <div class="channel-item-node-forwards">
            <span class="channel-item-node-forwards-count"><%= channel.forward_in_count + channel.forward_out_count %></span>
            <%= if channel.latest_forward_time != nil do %>
              <span>
              forwards, latest
              </span>
              <span class="channel-item-node-last-forward-date">
                <%= Timex.from_now(channel.latest_forward_time) %>
              </span>
            <% else %>
              forwards
            <% end %>
          </div>

        </div>

        <div>

          <div class="liquidity-metrics">
            <div class="channel-item-capacity"><%= channel.formatted_capacity %></div>
            <div class="channel-item-balance-percent"><%= channel.formatted_balance_percent %>%</div>
          </div>

          <.liquidity_meeter balance={channel.formatted_balance_percent} status={channel.status} />

        </div>
      </div>

    </div>
    """
  end
end
