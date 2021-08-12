defmodule Steer.Repo.Migrations.CreateChannelTable do
  use Ecto.Migration

  def change do
    create table(:channel) do
      add :lnd_id, :decimal, null: false
      add :channel_point, :string, null: false
      add :node_pub_key, :string, null: false
      add :is_active, :boolean, null: false
      add :alias, :string
      add :color, :string
      add :capacity, :decimal, null: false
      add :local_balance, :decimal, null: false
      add :remote_balance, :decimal, null: false

      timestamps
    end

    create unique_index(:channel, [:lnd_id])
    create unique_index(:channel, [:channel_point])
  end
end
