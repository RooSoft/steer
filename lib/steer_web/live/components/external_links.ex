defmodule SteerWeb.Components.ExternalLinks do
  use Phoenix.Component

  def external_links(assigns) do
    ~H"""
      <div class="external-link">
        <a href={"https://amboss.space/node/#{@pub_key}"}>
            <img src="/images/amboss.svg" width="140px">
        </a>
      </div>

      <div class="external-link">
        <a href={"https://1ml.com/node/#{@pub_key}"}>
            <img src="/images/1ml.png" width="50px">
        </a>
      </div>

      <div class="external-link">
        <a href={"https://terminal.lightning.engineering/#/#{@pub_key}"} class="external-links-terminal-link">
          <img src="/images/terminal.svg" width="20px">
          <span class="external-links-terminal-link-caption">TERMINAL</span>
        </a>
      </div>
    """
  end
end
