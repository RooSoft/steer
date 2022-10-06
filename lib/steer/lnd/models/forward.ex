defmodule Steer.Lnd.Models.Forward do
  def convert(lnd_forwards) do
    lnd_forwards
    |> create_map()
    |> format_amounts
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
        time: lnd_forward.time,
        timestamp_ns: lnd_forward.timestamp_ns
      }
    end)
  end

  defp format_amounts(forwards) do
    forwards
    |> Enum.map(fn forward ->
      formatted_amount_in =
        Number.SI.number_to_si(forward.amount_in / 1000, unit: "", precision: 1)

      formatted_amount_out =
        Number.SI.number_to_si(forward.amount_out / 1000, unit: "", precision: 1)

      formatted_fee = Number.SI.number_to_si(forward.fee / 1000, unit: "", precision: 1)

      forward
      |> Map.put(:formatted_amount_in, formatted_amount_in)
      |> Map.put(:formatted_amount_out, formatted_amount_out)
      |> Map.put(:formatted_fee, formatted_fee)
    end)
  end
end
