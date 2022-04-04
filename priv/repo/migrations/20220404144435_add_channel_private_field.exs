defmodule Steer.Repo.Migrations.AddChannelPrivateField do
  use Ecto.Migration

  def change do
    alter table(:channel) do
      add(:is_private, :boolean, null: false, default: false)
    end
  end
end
