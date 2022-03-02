defmodule SteerWeb.DiagnosticsLive.Lnd do
  use Phoenix.Component

  import SteerWeb.DiagnosticsLive.Logs
  import SteerWeb.DiagnosticsLive.StatusIndicator

  def lnd(assigns) do
    ~H"""
    <div class="diagnostics-lnd-info">
      <div class="diagnostics-lnd-info-version">
        Version <em><%= assigns.info.version %></em>
      </div>
    </div>

    <div class="diagnostics-status-and-logs">
      <.status_indicator connecting={assigns.connecting} />
      <.logs messages={@messages} />
    </div>
    """
  end
end
