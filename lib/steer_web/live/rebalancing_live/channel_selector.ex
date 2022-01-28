defmodule SteerWeb.RebalancingLive.ChannelSelector do
  use Phoenix.LiveComponent

  def render(assigns) do
    channel = assigns.channel

    ~H"""
    <div class="rebalancing-channel" phx-click="click" phx-target={@myself}>
      <span class="rebalancing-balance-value"><%= channel.formatted_balance_percent%>%</span>
      <span><%= channel.alias %></span>
      <span></span>
    </div>
    """
  end

  def handle_event("click", _, %{assigns: %{channel: channel}} = socket) do
    IO.puts("#{channel.alias} as been clicked ** from inside ChannelSelector")

    send(self(), {:channel_selected, socket.assigns.channel})

    {:noreply, socket}
  end
end
