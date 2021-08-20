defmodule Steer.LndSyncTimer do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_sync() # and then schedule next sync

    { :ok, state }
  end

  def handle_info(:sync, state) do
    Steer.Lightning.sync()

    schedule_sync()

    { :noreply, state }
  end

  defp schedule_sync() do
    now = DateTime.utc_now()
    today = Date.utc_today()
    { :ok, next_sync_date_time } = DateTime.new(today, ~T[00:01:00])
    next_sync_delay = DateTime.diff(now, next_sync_date_time, :millisecond)

    Process.send_after(self(), :sync, next_sync_delay) # tomorrow past midnight
  end
end
