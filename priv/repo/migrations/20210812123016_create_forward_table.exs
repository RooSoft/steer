defmodule Steer.Repo.Migrations.CreateForwardTable do
  use Ecto.Migration
  alias Steer.Lightning.ForwardDirection

  def change do
    ForwardDirection.create_type

    create table(:forward) do
      add :amount_in, :decimal, null: false
      add :amount_out, :decimal, null: false
      add :fee, :decimal, null: false
      add :direction, :forward_direction, values: [:in, :out], null: false
      add :channel_in_id, references(:channel), null: false
      add :channel_out_id, references(:channel), null: false
      add :timestamp, :naive_datetime_usec, null: false

      timestamps(inserted_at: :created_at, updated_at: :changed_at, type: :utc_datetime)
    end
  end
end
