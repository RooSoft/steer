defmodule SteerWeb.PageLive do
  use SteerWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket = socket
    |> assign(:channels, get_channels())

    {:ok, socket}
  end

  defp get_channels() do
    LndClient.get_channels().channels
    |> Enum.map(fn channel ->
      node_info = LndClient.get_node_info(channel.remote_pubkey)

      channel
      |> Map.put(:alias, node_info.node.alias)
    end)
  end
end
