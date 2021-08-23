defmodule Steer.Repo.Migrations.CreateHtlcTable do
  use Ecto.Migration

  def change do
    create table(:htlc) do
      timestamps()
    end
  end
end
