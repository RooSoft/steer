defmodule SteerWeb.Components.IndicatorsComponent do
  use Phoenix.Component

  def node_status_indicator(assigns) do
    ~H"""
    <div class={get_class(assigns.state)}></div>
    """
  end

  defp get_class(:active) do
    "indicator active-indicator"
  end

  defp get_class(_) do
    "indicator inactive-indicator"
  end
end
