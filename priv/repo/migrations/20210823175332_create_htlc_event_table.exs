defmodule Steer.Repo.Migrations.CreateHtlcEventTable do
  use Ecto.Migration

  alias Steer.Lightning.Enums.HtlcEventType

  def change do
    HtlcEventType.create_type()

    create table(:htlc_event) do
      add :type, :htlc_event_type, values: [:forward, :forward_fail, :settle, :link_fail], null: false
      add :channel_in_id, references(:channel), null: false
      add :channel_out_id, references(:channel), null: false
      add :htlc_in_id, references(:htlc), null: false
      add :htlc_out_id, references(:htlc), null: false
      add :time, :naive_datetime_usec, null: false
      add :timestamp_ns, :bigint, null: false

      timestamps()
    end
  end
end
