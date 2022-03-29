defmodule SteerWeb.ChannelLive.Components.Forwards do
  use Phoenix.Component

  alias SteerWeb.ChannelLive.ForwardsComponent

  def forwards(assigns) do
    ~H"""
    <.live_component module={ForwardsComponent}, id="forwards"
      content={%{
        channel: assigns.channel,
        forwards: assigns.forwards
    }} />
    """
  end
end
