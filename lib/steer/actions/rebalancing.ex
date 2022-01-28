defmodule Steer.Actions.Rebalancing do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rebalance_form" do
    field :source_channel_id, :integer
  end

  def changeset(rebalancing, attrs) do
    rebalancing
    |> cast(attrs, [:source_channel_id])
    |> validate_required([:source_channel_id])
  end
end
