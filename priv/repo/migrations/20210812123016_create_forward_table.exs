defmodule Steer.Repo.Migrations.CreateForwardTable do
  use Ecto.Migration

  def change do
    create table(:forward) do
      add :amount_in, :bigint, null: false
      add :amount_out, :bigint, null: false
      add :fee, :bigint, null: false
      add :channel_in_id, references(:channel), null: false
      add :channel_out_id, references(:channel), null: false
      add :consolidated, :boolean, default: false, null: false
      add :timestamp, :naive_datetime_usec, null: false

      timestamps()
    end
  end
end
