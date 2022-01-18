defmodule SteerWeb.ChannelLive.ChannelListComponent do
  use SteerWeb, :live_component

  import SteerWeb.ChannelLive.ChannelItemComponent

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:id, 0)}
  end
end
