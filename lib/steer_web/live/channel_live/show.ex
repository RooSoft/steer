defmodule SteerWeb.ChannelLive.Show do
  use SteerWeb, :live_view

  @impl true
  def handle_params(%{"id" => id_string}, _, socket) do
    { id, _ } = Integer.parse(id_string)

    {:noreply,
      socket
      |> assign(:channel, Steer.Lightning.get_channel(%{ id: id}))
      |> assign(:forwards, Steer.Lightning.get_channel_forwards(id))}
  end
end
