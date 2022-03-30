defmodule SteerWeb.ChannelLive.Components.Liquidity do
  use Phoenix.Component

  def liquidity(assigns) do
    ~H"""
    <div class="channel-liquidity-details">
      <div class="section-header">Allocation</div>
      <div>
        <em><%= @channel.formatted_capacity %></em>
        <span class="text-xs">sats, </span>
        <em><%= @channel.formatted_balance_percent %></em>%
        <span class="text-xs">local</span>
      </div>
      <div>
        <em><%= @channel.formatted_local_balance %></em>
        <span class="text-xs">sats local</span>
      </div>
      <div>
        <em><%= @channel.formatted_remote_balance %></em>
        <span class="text-xs">sats remote</span>
      </div>
    </div>

    <div class="channel-liquidity-fees">
      <div class="section-header">Fees</div>

      <table class="channel-liquidity-fees-table">
        <tbody>
          <tr>
            <th></th>
            <th class="channel-liquidity-fees-header">base</th>
            <th class="channel-liquidity-fees-header">rate</th>
          </tr>
          <tr>
            <td class="channel-liquidity-fees-label">local</td>
            <td class="channel-liquidity-fees-value-cell">
              <span class="channel-liquidity-fees-value"><%= @fee_structure.local.base / 1000 %></span>
              <span class="channel-liquidity-fees-unit">sats</span>
            </td>
            <td class="channel-liquidity-fees-value-cell">
              <span class="channel-liquidity-fees-value"><%= @fee_structure.local.rate %></span>
              <span class="channel-liquidity-fees-unit">PPM</span>
            </td>
          </tr>
          <tr>
            <td class="channel-liquidity-fees-label">remote</td>
            <td class="channel-liquidity-fees-value-cell">
              <span class="channel-liquidity-fees-value"><%= @fee_structure.remote.base / 1000 %></span>
              <span class="channel-liquidity-fees-unit">sats</span>
            </td>
            <td class="channel-liquidity-fees-value-cell">
              <span class="channel-liquidity-fees-value"><%= @fee_structure.remote.rate %></span>
              <span class="channel-liquidity-fees-unit">PPM</span>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end
end
