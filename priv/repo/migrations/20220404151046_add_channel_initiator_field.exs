defmodule Steer.Repo.Migrations.AddChannelInitiatorField do
  use Ecto.Migration

  def change do
    alter table(:channel) do
      add(:is_initiator, :boolean, null: false, default: false)
    end
  end
end
