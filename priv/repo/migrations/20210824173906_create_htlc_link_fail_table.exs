defmodule Steer.Repo.Migrations.CreateHtlcLinkFailTable do
  use Ecto.Migration

  def change do
    create table(:htlc_link_fail) do
      add :amount_in, :bigint, null: false
      add :amount_out, :bigint, null: false
      add :timelock_in, :bigint, null: false
      add :timelock_out, :bigint, null: false

      add :wire_failure, :string, null: false
      add :failure_detail, :string, null: false
      add :failure_string, :text

      add :htlc_event_id, references(:htlc_event), null: false

      timestamps()
    end
  end
end
