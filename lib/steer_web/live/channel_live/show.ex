defmodule SteerWeb.ChannelLive.Show do
  use SteerWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
      socket
      |> assign(:channel, id)}
  end
end
