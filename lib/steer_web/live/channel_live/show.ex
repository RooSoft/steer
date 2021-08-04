defmodule SteerWeb.ChannelLive.Show do
  use SteerWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id_string}, _, socket) do
    { id, _ } = Integer.parse(id_string)

    {:noreply,
      socket
      |> assign(:channel, Steer.Lnd.get_channel(id))}
  end
end
