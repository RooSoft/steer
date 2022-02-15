defmodule Steer.Repo.Migrations.CreateChannelFeesTable do
  use Ecto.Migration

  def change do
    create table(:channel_fees) do
      add :channel_in_id, references(:channel), null: false

      add :local_base, :int, null: false
      add :local_rate, :int, null: false
      add :remote_base, :int, null: false
      add :remote_rate, :int, null: false

      timestamps()
    end
  end
end
