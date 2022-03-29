defmodule SteerWeb.ChannelLive.Components.About do
  use Phoenix.Component

  import SteerWeb.Components.ExternalLinks
  import SteerWeb.Components.ShortPubKey

  import SteerWeb.Components.ExternalLinks

  def about(assigns) do
    channel = assigns.channel

    ~H"""
    <div x-data={"{ active: #{channel.status == :active}, pubKey: '#{channel.node_pub_key}' }"}>
      <div class="channel-about-node-pub-key">
        <.short_pub_key pub_key={channel.node_pub_key} />
      </div>

      <div class="channel-about-node-lnd-id">
        Channel id: <%= channel.lnd_id %>
      </div>
    </div>

    <div class="channel-show-external-links">
      <.external_links pub_key={channel.node_pub_key} />
    </div>
    """
  end
end
