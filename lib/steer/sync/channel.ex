defmodule Steer.Sync.Channel do
  alias Steer.Repo, as: Repo
  alias Steer.Lightning.Models, as: Models

  def sync() do
    LndClient.get_channels().channels
    |> Enum.each(&upsert_channel/1)

    LndClient.get_closed_channels().channels
    |> Enum.each(&upsert_closed_channel/1)

  end

  defp upsert_channel channel do
    convert_channel_to_map(channel)
    |> upsert_channel_map()
  end

  defp upsert_closed_channel closed_channel do
    convert_closed_channel_to_map(closed_channel)
    |> upsert_channel_map
  end

  defp upsert_channel_map map do
    changeset = Models.Channel.changeset(
      %Models.Channel{},
      map
    )

    { :ok, _ } = Repo.insert(
      changeset,
      on_conflict: [set: [
        alias: map.alias,
        color: map.color,
        local_balance: map.local_balance,
        remote_balance: map.remote_balance,
        status: map.status
      ]],
      conflict_target: :channel_point
    )
  end

  defp convert_channel_to_map channel do
    node = LndClient.get_node_info(channel.remote_pubkey).node

    %{
      lnd_id: channel.chan_id,
      channel_point: channel.channel_point,
      node_pub_key: channel.remote_pubkey,
      status: get_channel_status(channel),
      alias: node.alias,
      color: node.color,
      capacity: channel.capacity * 1000,
      local_balance: channel.local_balance * 1000,
      remote_balance: channel.remote_balance * 1000
    }
  end

  defp convert_closed_channel_to_map channel do
  #  node = LndClient.get_node_info(channel.remote_pubkey).node

    %{
      lnd_id: channel.chan_id,
      channel_point: channel.channel_point,
      node_pub_key: channel.remote_pubkey,
      status: :closed,
      alias: "TODO",
      color: "TODO",
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
