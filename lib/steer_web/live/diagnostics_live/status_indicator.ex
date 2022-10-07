defmodule SteerWeb.DiagnosticsLive.StatusIndicator do
  use Phoenix.Component

  def status_indicator(assigns) do
    ~H"""
    <div class="">
      <div
        x-bind:title="is_lnd_node_online ? 'online' : 'offline'"
        x-bind:class="is_lnd_node_online ? 'header-node-online' : 'header-node-offline'"
        class="diagnostics-status-icon">
      </div>

      <button phx-click="connect"
        x-bind:class="css.getNodeStatusColor(connecting)"
        x-bind:hidden="is_lnd_node_online"
        class="diagnostics-connect-button"
        x-bind:name="connecting ? 'working' : 'connect'"
        x-bind:style="connecting ? 'cursor: wait' : 'cursor: pointer'"
        x-bind:disabled="connecting">
        <%= case @connecting do true -> "connecting..."; false -> "connect" end  %>
      </button>
    </div>
    """
  end
end
