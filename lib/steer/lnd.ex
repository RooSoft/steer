defmodule Steer.Lnd do
  alias Steer.Lnd.Channel

  def get_all_channels(args) do
    get_lnd_channels()
    |> Channel.convert(args)
    |> add_node_info()
  end

  defp get_lnd_channels() do
    LndClient.get_channels().channels
  end

  defp add_node_info(channels) do
    channels
    |> Enum.map(fn channel ->
      node_info = LndClient.get_node_info(channel.node_pubkey)

      channel
      |> Channel.add_node_info(node_info.node)
    end)
  end
end
