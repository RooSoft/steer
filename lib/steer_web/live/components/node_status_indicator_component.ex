defmodule SteerWeb.Components.NodeStatusIndicatorComponent do
  use Phoenix.Component

  def node_status_indicator(assigns) do
    ~H"""
    <div class={get_class(assigns.status)}></div>
    """
  end

  defp get_class(:active) do
    "node-status-indicator active-node-status-indicator"
  end

  defp get_class(_) do
    "node-status-indicator inactive-node-status-indicator"
  end
end
