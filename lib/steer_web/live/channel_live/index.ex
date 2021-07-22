defmodule SteerWeb.ChannelLive.Index do
  use SteerWeb, :live_component

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
