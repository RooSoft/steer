defmodule SteerWeb.Components.ShortPubKey do
  use Phoenix.Component

  def short_pub_key(assigns) do
    ~H"""
    <div class="short-pub-key" x-data={"{ pubKey: '#{assigns.channel.formatted_node_pub_key}' }"}>
      <%= assigns.channel.formatted_node_pub_key %>
      <template x-if="window.location.protocol === 'https:'">
        <button class="short-pub-key-clipboard-icon" @click.stop="event.preventDefault();$clipboard(pubKey);">
          <img src="/images/clipboard.svg">
        </button>
      </template>
    </div>
    """
  end
end
