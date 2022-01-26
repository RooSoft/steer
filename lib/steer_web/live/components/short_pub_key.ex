defmodule SteerWeb.Components.ShortPubKey do
  use Phoenix.Component

  def short_pub_key(assigns) do
    formatted_pub_key = format_pub_key(assigns.pub_key)

    ~H"""
    <div class="short-pub-key" x-data={"{ pubKey: '#{assigns.pub_key}' }"}>
      <%= formatted_pub_key %>
      <template x-if="window.location.protocol === 'https:'">
        <div class="short-pub-key-clipboard-icon" @click.stop="event.preventDefault();$clipboard(pubKey);">
          <img src="/images/clipboard.svg">
        </div>
      </template>
    </div>
    """
  end

  def format_pub_key(pub_key) do
    Steer.Formatting.Channel.compressed_pub_key(pub_key)
  end
end
