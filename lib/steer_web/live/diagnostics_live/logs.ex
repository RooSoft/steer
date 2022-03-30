defmodule SteerWeb.DiagnosticsLive.Logs do
  use Phoenix.Component

  def logs(assigns) do
    ~H"""
    <div class="">
      <span class="diagnostics-log-title">Log</span>
      <div class="diagnostics-logs-details">
        <%= for message <- Enum.reverse @messages do %>
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
