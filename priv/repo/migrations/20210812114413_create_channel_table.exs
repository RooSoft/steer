defmodule Steer.Repo.Migrations.CreateChannelTable do
  use Ecto.Migration
  alias Steer.Lightning.Enums.ChannelStatus

  def change do
    ChannelStatus.create_type()

    create table(:channel) do
      add :lnd_id, :bigint, null: false
      add :channel_point, :string, null: false
      add :node_pub_key, :string, null: false
      add :status,:channel_status, values: [:active, :inactive, :closed], null: false
      add :alias, :string
      add :color, :string
      add :capacity, :bigint, null: false
      add :local_balance, :bigint, null: false
      add :remote_balance, :bigint, null: false

      timestamps()
    end

    create unique_index(:channel, [:lnd_id])
    create unique_index(:channel, [:channel_point])
  end
end
