defmodule Steer.Sync.Forward do
  alias Steer.Repo, as: Repo
  alias Steer.Lightning.Models, as: Models

  def sync() do

    LndClient.get_forwarding_history().forwarding_events
    |> Enum.each(&insert_forward/1)
  end

  defp insert_forward forward do
    map = convert_forward_to_map(forward)

    changeset = Models.Forward.changeset(
      %Models.Forward{},
      map
    )

    { :ok, _ } = Repo.insert(changeset)
  end

  defp convert_forward_to_map forward do
    %{
      amount_in: forward.amt_in_msat,
      amount_out: forward.amt_out_msat,
      fee: forward.fee_msat,
      channel_in_id: Repo.get_channel_by_lnd_id(forward.chan_id_in).id,
      channel_out_id: Repo.get_channel_by_lnd_id(forward.chan_id_out).id,
      timestamp: forward.timestamp |> DateTime.from_unix!(:second) |> DateTime.to_naive
    }
  end
end
