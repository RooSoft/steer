defmodule SteerWeb.ChannelLive.ListComponent do
  use SteerWeb, :live_component

  import SteerWeb.Components.NodeStatusIndicatorComponent

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:id, 0)}
  end
end
