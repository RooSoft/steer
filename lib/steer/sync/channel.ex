defmodule Steer.Sync.Channel do
  alias Steer.Repo, as: Repo
  alias Steer.Lightning.Models, as: Models

  def sync() do
    LndClient.get_channels().channels
    |> Enum.each(fn channel ->
      upsert_channel_in_database channel
    end)
  end

  defp upsert_channel_in_database channel do
    map = convert_struct_to_map(channel)

    changeset = Models.Channel.changeset(
      %Models.Channel{},
      map
    )

    { :ok, _ } = Repo.insert(
      changeset,
      on_conflict: [set: [
        local_balance: map.local_balance,
        remote_balance: map.remote_balance,
        is_active: map.is_active
      ]],
      conflict_target: :channel_point
    )
  end

  defp convert_struct_to_map channel do
    %{
      lnd_id: channel.chan_id,
      channel_point: channel.channel_point,
      node_pub_key: channel.remote_pubkey,
      is_active: channel.active,
      alias: "TODO",
      color: "TODO",
      capacity: channel.capacity,
      local_balance: channel.local_balance,
      remote_balance: channel.remote_balance,
    }
  end
end
