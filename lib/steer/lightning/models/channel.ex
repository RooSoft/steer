defmodule Steer.Lightning.Models.Channel do
  use Ecto.Schema
  import Ecto.Changeset

  alias Steer.Lightning.Models

  schema "channel" do
    field :lnd_id, :decimal
    field :channel_point, :string
    field :node_pub_key, :string
    field :status, Ecto.Enum, values: [:active, :inactive, :closed]
    field :alias, :string
    field :color, :string
    field :capacity, :decimal
    field :local_balance, :decimal
    field :remote_balance, :decimal

    has_many :forwards_in, Models.Forward, foreign_key: :channel_in_id
    has_many :forwards_out, Models.Forward, foreign_key: :channel_out_id

    timestamps()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:lnd_id, :channel_point, :node_pub_key, :status, :alias, :color, :capacity, :local_balance, :remote_balance])
    |> validate_required([:lnd_id, :channel_point, :node_pub_key, :status, :capacity, :local_balance, :remote_balance])
  end
end
