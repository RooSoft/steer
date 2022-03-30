defmodule SteerWeb.DiagnosticsLive.StatusIndicator do
  use Phoenix.Component

  def status_indicator(assigns) do
    ~H"""
    <div class="">
      <div
        :title="is_lnd_node_online ? 'online' : 'offline'"
        :class="is_lnd_node_online ? 'header-node-online' : 'header-node-offline'"
        class="diagnostics-status-icon">
      </div>

      <button phx-click="connect"
        :class="css.getNodeStatusColor(connecting)"
        :hidden="is_lnd_node_online"
        class="diagnostics-connect-button"
        :name="connecting ? 'working' : 'connect'"
        :style="connecting ? 'cursor: wait' : 'cursor: pointer'"
        :disabled="connecting">
        <%= case @connecting do true -> "connecting..."; false -> "connect" end  %>
      </button>
    </div>
    """
  end
end
