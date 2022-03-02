defmodule SteerWeb.DiagnosticsLive.About do
  use Phoenix.Component

  import SteerWeb.Components.ExternalLinks
  import SteerWeb.Components.ShortPubKey

  def about(assigns) do
    ~H"""
    <div>Steer v<%= @version %></div>

    <div class="diagnostics-about-live-node-name"><%= assigns.node.alias %></div>

    <div class="diagnostics-about-live-pub-key">
      <.short_pub_key pub_key={assigns.node.pubkey} />
    </div>

    <div class="diagnostics-about-info-chains">
      <%= for chain <- assigns.info.chains do %>
        <%= chain.chain %> <%= chain.network %>
      <% end %>
    </div>

    <div class="diagnostics-about-info-uris">
      <div class="diagnostics-about-info-uris-title">
        URI list
      </div>
      <ul>
        <%= for uri <- assigns.info.uris do %>
          <li class="diagnostics-about-info-uri" x-data={"{ uri: '#{uri}' }"}>
            <div class="diagnostics-about-info-uri-string">
              <%= uri %>
            </div>
            <template x-if="window.location.protocol === 'https:'">
              <div class="uri-clipboard-icon" @click.stop="event.preventDefault();$clipboard(uri);">
                <img src="/images/clipboard.svg">
              </div>
            </template>
          </li>
        <% end %>
      </ul>
    </div>

    <.external_links pub_key={@node.pubkey} />
    """
  end
end
