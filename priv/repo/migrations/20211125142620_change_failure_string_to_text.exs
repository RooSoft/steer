defmodule Steer.Repo.Migrations.ChangeFailureStringToText do
  use Ecto.Migration

  def change do
    alter table(:htlc_link_fail) do
      modify :failure_string, :text
    end
  end
end
