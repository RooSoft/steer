defmodule Steer.Repo.Migrations.CreateHtlcEventTable do
  use Ecto.Migration

  #  alias Steer.Lightning.Enums.HtlcEventType

  def change do
    #    HtlcEventType.create_type()

    create table(:htlc_event) do
      add :type, :string, values: [:forward, :forward_fail, :settle, :link_fail], null: false
      add :channel_in_id, references(:channel), null: true
      add :channel_out_id, references(:channel), null: true
      add :htlc_in_id, :bigint, null: false
      add :htlc_out_id, :bigint, null: false
      add :timestamp_ns, :bigint, null: false

      timestamps()
    end
  end
end
