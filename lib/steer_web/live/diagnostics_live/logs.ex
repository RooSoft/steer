defmodule SteerWeb.DiagnosticsLive.Logs do
  use Phoenix.Component

  def logs(assigns) do
    ~H"""
    <div class="mx-4 flex-1">
      <span class="diagnostics-log-title">Log</span>
      <div class="diagnostics-connect-button">
        <%= for message <- Enum.reverse assigns.messages do %>
          <div>
            <span class="diagnostics-logs-date">
              <%= message.date %>
            </span>
            <span class="diagnostics-logs-time">
              <%= message.time %>
            </span>
            <span class="diagnostics-logs-text">
              <%= message.text %>
            </span>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
