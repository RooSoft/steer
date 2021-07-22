defmodule Steer.Lnd.Forward do
  def convert(lnd_forwards) do
    lnd_forwards
    |> create_map()
    |> format_timestamps()
  end

  defp create_map(lnd_forwards) do
    lnd_forwards
    |> Enum.map(fn lnd_forward ->
      %{
        amount_in: lnd_forward.amt_in_msat,
        amount_out: lnd_forward.amt_out_msat,
        chan_id_in: lnd_forward.chan_id_in,
        chan_id_out: lnd_forward.chan_id_out,
        fee: lnd_forward.fee_msat,
        timestamp: lnd_forward.timestamp
      }
    end)
  end

  defp format_timestamps(forwards) do
    forwards
    |> Enum.map(fn forward ->
      forward
      |> Map.put(:time, DateTime.from_unix!(forward.timestamp))
    end)
  end
end
