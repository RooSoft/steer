defmodule Steer.Repo.Migrations.CreateLocalNodeTable do
  use Ecto.Migration

  def change do
    create table(:local_node) do
      add :pubkey, :string, null: false
      add :alias, :string, null: true
      add :color, :string, null: true
      add :commit_hash, :string, null: false
      add :is_testnet, :boolean, null: false
      add :uris, {:array, :string}, null: false

      timestamps()
    end
  end
end
