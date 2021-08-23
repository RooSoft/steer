defmodule Steer.Sync.Forward do
  alias Steer.Repo, as: Repo
  alias Steer.Lightning.Models, as: Models

  @max_events_per_lnd_call 10000
  @hours_in_day 24
  @minutes_in_hour 60
  @seconds_in_minute 60
  @one_day @hours_in_day * @minutes_in_hour * @seconds_in_minute

  def sync() do
    time = get_latest_unconsolidated_forward_time()

    sync(time)
  end

  @spec sync(%{:calendar => any, :day => any, :month => any, :year => any, optional(any) => any}) ::
          nil
  def sync(time) do
    execute_if_not_tomorrow(time, &do_sync/1)
  end

  defp do_sync(date) do
    context = %{
      max_events: @max_events_per_lnd_call,
      date: date
    }
    |> compute_date_range
    |> add_lnd_forwarding_events
    |> add_repo_forwarding_events
    |> find_new_forwards_in_lnd
    |> insert_new_forwards_in_lnd
    |> maybe_mark_as_consolidated

    next_day = DateTime.to_date(context.end_time)

    execute_if_not_tomorrow(next_day, &do_sync/1)
  end

  defp compute_date_range context do
    { :ok, start_time } = DateTime.new(context.date, ~T[00:00:00], "Etc/UTC")
    end_time = DateTime.add(start_time, @one_day)

    context
    |> Map.put(:start_time, start_time)
    |> Map.put(:end_time, end_time)
  end

  defp add_lnd_forwarding_events context  do
    { :ok, forwarding_history } = %{
      start_time: context.start_time,
      end_time: context.end_time
    }
    |> LndClient.get_forwarding_history()

    context
    |> Map.put(:lnd_forwards, forwarding_history.forwarding_events)
  end

  defp add_repo_forwarding_events context do
    repo_forwards = %{
      start_time: context.start_time,
      end_time: context.end_time
    }
    |> Repo.get_forwards_in_date_range

    context
    |> Map.put(:repo_forwards, repo_forwards)
  end

  defp find_new_forwards_in_lnd(%{ repo_forwards: repo_forwards } = context)
  when length(repo_forwards) == 0 do
    context
    |> Map.put(:new_forwards_in_lnd, context.lnd_forwards)
  end

  defp find_new_forwards_in_lnd context do
    new_forwards_in_lnd = context.lnd_forwards
    |> Enum.filter(fn lnd_forward ->
      context.repo_forwards
      |> Enum.find_index(fn repo_forward ->
        compare_forwards(lnd_forward, repo_forward)
      end) == nil
    end)

    context
    |> Map.put(:new_forwards_in_lnd, new_forwards_in_lnd)
  end

  defp get_latest_unconsolidated_forward_time() do
    get_repo_latest_unconsolidated_forward_time()
    |> maybe_get_repo_latest_forward_timestamp
    |> maybe_get_lnd_first_forward_timestamp
    |> NaiveDateTime.to_date
  end

  defp maybe_get_repo_latest_forward_timestamp nil do
    case Repo.get_latest_forward() do
      %{ timestamp: timestamp } ->
        timestamp
      nil ->
        nil
    end
  end

  defp maybe_get_repo_latest_forward_timestamp timestamp do
    timestamp
  end

  defp maybe_get_lnd_first_forward_timestamp nil do
    case LndClient.get_forwarding_history %{ max_events: 1 } do
      { :ok, %{ forwarding_events: [] } } ->
        ~N[2000-01-01 00:00:00]
      { :ok, %{ forwarding_events: [first_forward | _] } } ->
        first_forward.time
      { :error, _ } ->
        ~N[2000-01-01 00:00:00]
    end
  end

  defp maybe_get_lnd_first_forward_timestamp timestamp do
    timestamp
  end

  defp get_repo_latest_unconsolidated_forward_time do
    case Repo.get_latest_unconsolidated_forward() do
      %{ time: time } ->
        time
      nil ->
        nil
    end
  end

  defp compare_forwards(%{
    amt_in_msat: lnd_amount_in,
    amt_out_msat: lnd_amount_out,
    chan_id_in: lnd_channel_id_in,
    chan_id_out: lnd_channel_id_out,
    fee_msat: lnd_fee,
    time: lnd_timestamp
  }, %{
    amount_in: repo_amount_in,
    amount_out: repo_amount_out,
    channel_in: repo_channel_in,
    channel_out: repo_channel_out,
    fee: repo_fee,
    timestamp: repo_timestamp
  }) when lnd_amount_in == repo_amount_in
      and lnd_amount_out == repo_amount_out
      and lnd_channel_id_in == repo_channel_in.lnd_id
      and lnd_channel_id_out == repo_channel_out.lnd_id
      and lnd_fee == repo_fee
      and lnd_timestamp == repo_timestamp do
    true
  end

  defp compare_forwards _lnd_forward, _repo_forward do
    false
  end

  defp insert_new_forwards_in_lnd context do
    inserted_ids = context.new_forwards_in_lnd
    |> Enum.map(&insert_forward/1)

    if context |> Map.has_key?(:inserted_ids) do
      context |> Map.put(:inserted_ids,
        context |> Map.get(:inserted_ids)
        |> Enum.concat(inserted_ids)
      )
    else
      context |> Map.put(:inserted_ids, inserted_ids)
    end
  end

  defp maybe_mark_as_consolidated context do
    today = Date.utc_today()

    case Date.compare(context.date, today) do
      :lt -> context |> mark_as_consolidated
      :eq -> context
      :gt -> context
    end
  end

  defp mark_as_consolidated context do
    if Enum.any? context.inserted_ids do
      Repo.mark_forwards_as_consolidated context.inserted_ids
    end

    context
  end

  defp insert_forward forward do
    map = convert_forward_to_map(forward)

    changeset = Models.Forward.changeset(
      %Models.Forward{},
      map
    )

    { :ok, inserted } = Repo.insert(changeset)

    inserted.id
  end

  defp convert_forward_to_map forward do
    %{
      amount_in: forward.amt_in_msat,
      amount_out: forward.amt_out_msat,
      fee: forward.fee_msat,
      channel_in_id: Repo.get_channel_by_lnd_id(forward.chan_id_in).id,
      channel_out_id: Repo.get_channel_by_lnd_id(forward.chan_id_out).id,
      time: forward.time,
      timestamp_ns: forward.timestamp_ns
    }
  end

  defp execute_if_not_tomorrow date, callback do
    today = Date.utc_today()

    case Date.compare(date, today) do
      :lt -> callback.(date)
      :eq -> callback.(date)
      :gt -> nil
    end
  end
end
