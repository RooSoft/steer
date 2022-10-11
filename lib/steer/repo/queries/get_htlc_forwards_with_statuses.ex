defmodule Steer.Repo.Queries.GetHtlcForwardsWithStatuses do
  require Logger

  import Ecto.Query

  alias Steer.Lightning.Models, as: Models

  def get_query(options \\ []) do
    defaults = %{from_forward_htlc_id: nil, limit: 10, offset: 0}
    options = Enum.into(options, defaults)

    Logger.debug(
      "GetHtlcForwardsWithStatuses - from forward HTLC id #{options.from_forward_htlc_id} limit #{options.limit} "
    )

    main_query()
    |> maybe_add_limit(options.limit)
    |> maybe_add_offset(options.offset)
    |> maybe_from_forward_id(options.from_forward_htlc_id)
  end

  defp maybe_add_limit(query, nil), do: query

  defp maybe_add_limit(query, limit_number) do
    query
    |> limit(^limit_number)
  end

  defp maybe_add_offset(query, nil), do: query

  defp maybe_add_offset(query, offset_number) do
    query
    |> offset(^offset_number)
  end

  defp maybe_from_forward_id(query, nil), do: query

  defp maybe_from_forward_id(query, from_forward_htlc_id) do
    query
    |> where([_hf, htlc], htlc.id <= ^from_forward_htlc_id)
  end

  defp main_query do
    from hf in Models.HtlcForward,
      join: htlc in Models.HtlcEvent,
      on: hf.htlc_event_id == htlc.id,
      left_join: fail in Models.HtlcEvent,
      on:
        fail.htlc_in_id == htlc.htlc_in_id and
          fail.htlc_out_id == htlc.htlc_out_id and
          fail.type == :forward_fail,
      left_join: settle in Models.HtlcEvent,
      on:
        settle.htlc_in_id == htlc.htlc_in_id and
          settle.htlc_out_id == htlc.htlc_out_id and
          settle.type == :settle,
      left_join: ci in Models.Channel,
      on: ci.id == htlc.channel_in_id,
      left_join: co in Models.Channel,
      on: co.id == htlc.channel_out_id,
      order_by: [desc: htlc.timestamp_ns],
      select: %{
        htlc_id: htlc.id,
        fail_id: fail.id,
        settle_id: settle.id,
        channel_in_id: ci.id,
        channel_in: ci.alias,
        channel_out_id: co.id,
        channel_out: co.alias,
        amount_in: hf.amount_in,
        amount_out: hf.amount_out,
        timestamp_ns: htlc.timestamp_ns
      }
  end
end
