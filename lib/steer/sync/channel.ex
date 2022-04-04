defmodule Steer.Sync.Channel do
  require Logger

  alias Steer.Repo, as: Repo
  alias Steer.Lightning.Models, as: Models

  @unable_to_find_node_code 5

  def sync() do
    {:ok, channels} = LndClient.get_channels()
    {:ok, closed_channels} = LndClient.get_closed_channels()

    channels.channels
    |> Enum.each(&upsert_channel/1)

    closed_channels.channels
    |> Enum.each(&upsert_closed_channel/1)
  end

  defp upsert_channel(channel) do
    channel
    |> convert_channel_to_map
    |> filter_already_closed_channels
    |> maybe_upsert_channel_map()
  end

  defp filter_already_closed_channels(nil) do
    nil
  end

  defp filter_already_closed_channels(channel_map) do
    case Steer.Lightning.get_channel(channel_point: channel_map.channel_point) do
      %{status: :closed} = channel ->
        Logger.info("Skipping sync of #{channel.alias} cause it's already closed")
        nil

      _ ->
        channel_map
    end
  end

  defp upsert_closed_channel(closed_channel) do
    closed_channel
    |> convert_closed_channel_to_map
    |> maybe_upsert_channel_map
  end

  defp maybe_upsert_channel_map(nil) do
    Logger.info("No channel to upsert")
  end

  defp maybe_upsert_channel_map(map) do
    changeset =
      Models.Channel.changeset(
        %Models.Channel{},
        map
      )

    {:ok, _} =
      Repo.insert(
        changeset,
        on_conflict: [
          set: [
            alias: map.alias,
            color: map.color,
            is_private: map.is_private,
            is_initiator: map.is_initiator,
            local_balance: map.local_balance,
            remote_balance: map.remote_balance,
            status: map.status
          ]
        ],
        conflict_target: :channel_point
      )
  end

  defp convert_channel_to_map(channel) do
    case LndClient.get_node_info(channel.remote_pubkey) do
      {:error, %GRPC.RPCError{status: @unable_to_find_node_code}} ->
        nil

      {:ok, node_info} ->
        node = node_info.node

        %{
          lnd_id: channel.chan_id,
          channel_point: channel.channel_point,
          node_pub_key: channel.remote_pubkey,
          status: get_channel_status(channel),
          alias: node.alias,
          color: node.color,
          is_private: channel.private,
          is_initiator: !channel.initiator,
          capacity: channel.capacity * 1000,
          local_balance: channel.local_balance * 1000,
          remote_balance: channel.remote_balance * 1000
        }
    end
  end

  defp convert_closed_channel_to_map(channel) do
    node =
      case LndClient.get_node_info(channel.remote_pubkey) do
        {:ok, node_info} ->
          node_info.node

        {:error, _} ->
          %{
            alias: "--UNKNOWN--",
            color: "#000000"
          }
      end

    %{
      lnd_id: channel.chan_id,
      channel_point: channel.channel_point,
      node_pub_key: channel.remote_pubkey,
      status: :closed,
      alias: node.alias,
      color: node.color,
      is_private: false,
      is_initiator: false,
      capacity: channel.capacity * 1000,
      local_balance: 0,
      remote_balance: 0
    }
  end

  defp get_channel_status(%{active: true}) do
    :active
  end

  defp get_channel_status(%{active: false}) do
    :inactive
  end
end
