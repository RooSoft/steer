defmodule SteerWeb.RebalancingLive do
  use SteerWeb, :live_view
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> get_channels
     |> add_source_channels_list}
  end

  defp get_channels(socket) do
    socket
    |> assign(:channels, Steer.Lightning.get_all_channels())
  end

  defp add_source_channels_list(%{assigns: %{channels: channels}} = socket) do
    socket
  end
end
