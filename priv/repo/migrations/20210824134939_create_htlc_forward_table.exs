defmodule Steer.Repo.Migrations.CreateHtlcForwardTable do
  use Ecto.Migration

  def change do
    create table(:htlc_forward) do
      add :amount_in, :bigint, null: false
      add :amount_out, :bigint, null: false
      add :timelock_in, :bigint, null: false
      add :timelock_out, :bigint, nuill: false
      add :htlc_event_id, references(:htlc_event), null: false

      timestamps()
    end
  end
end
