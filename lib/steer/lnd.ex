defmodule Steer.Lnd do
  alias Steer.Lnd.{Channel, Forward}

  def get_all_channels() do
    get_lnd_channels()
    |> Channel.convert_list()
    |> add_node_info()
    |> include_forwards()
    |> Channel.sort_by_latest_forward_descending
  end

  def get_channel(id) do
    get_all_channels()
    |> Enum.find(fn channel ->
      channel.id == id
    end)
  end

  def get_all_forwards() do
    get_lnd_forwards()
    |> Forward.convert()
  end

  defp get_lnd_channels() do
    LndClient.get_channels().channels
  end

  defp get_lnd_forwards() do
    LndClient.get_forwarding_history(%{max_events: 1000}).forwarding_events
  end

  defp include_forwards(channels) do
    forwards = get_lnd_forwards()
    |> Forward.convert()

    channels
    |> Steer.Mashups.ChannelForwards.combine(forwards)
  end

  defp add_node_info(channels) when is_list(channels) do
    channels
    |> Enum.map(&add_node_info/1)
  end

  defp add_node_info(channel) do
    node_info = LndClient.get_node_info(channel.node_pubkey)

    channel
    |> Channel.add_node_info(node_info.node)
  end
end
