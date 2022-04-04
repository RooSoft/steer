defmodule SteerWeb.Components.ChannelId do
  use Phoenix.Component

  import SteerWeb.Components.NodeStatusIndicatorComponent

  def channel_id(assigns) do
    ~H"""
    <div class="channel-id-alias">
      <div class="channel-id-node-status-indicator">
        <.node_status_indicator status={@channel.status} />
      </div>

      <div phx-click="">
        <%= if @channel.is_private do %>
          <span title="private channel">🥷</span>
        <% end %>
        <%= if @channel.is_initiator do %>
          <span title="channel initiator">✨</span>
        <% end %>
        <%= @channel.alias %>
      </div>
    </div>
    """
  end
end
