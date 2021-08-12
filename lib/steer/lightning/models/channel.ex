defmodule Steer.Lightning.Models.Channel do
  use Ecto.Schema
  import Ecto.Changeset

  schema "channel" do
    field :lnd_id, :decimal
    field :channel_point, :string
    field :node_pub_key, :string
    field :is_active, :boolean
    field :alias, :string
    field :color, :string
    field :capacity, :decimal
    field :local_balance, :decimal
    field :remote_balance, :decimal

    timestamps()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:lnd_id, :channel_point, :node_pub_key, :is_active, :alias, :color, :capacity, :local_balance, :remote_balance])
    |> validate_required([:lnd_id, :channel_point, :node_pub_key, :is_active, :capacity, :local_balance, :remote_balance])
  end
end
