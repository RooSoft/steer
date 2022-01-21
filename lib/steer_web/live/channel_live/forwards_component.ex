defmodule SteerWeb.ChannelLive.ForwardsComponent do
  use SteerWeb, :live_component

  def mount(_, socket, _) do
    IO.puts("------------------")
    IO.inspect(socket.assigns)
    {:ok, socket}
  end
end
