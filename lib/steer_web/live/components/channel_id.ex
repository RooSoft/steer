defmodule SteerWeb.Components.ChannelId do
  use Phoenix.Component

  import SteerWeb.Components.NodeStatusIndicatorComponent

  def channel_id(assigns) do
    channel = assigns.channel

    ~H"""
    <div class="channel-id-alias">
      <div class="channel-id-node-status-indicator">
        <.node_status_indicator status={channel.status} />
      </div>

      <div phx-click="">
        <%= channel.alias %>
      </div>
    </div>
    """
  end
end
