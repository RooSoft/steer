defmodule Steer.Lightning.Models.LocalNode do
  use Ecto.Schema
  import Ecto.Changeset

  schema "local_node" do
    field :pubkey, :string
    field :alias, :string
    field :color, :string
    field :commit_hash, :string
    field :is_testnet, :boolean
    field :uris, {:array, :string}

    timestamps()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:pubkey, :alias, :color, :commit_hash, :is_testnet, :uris])
    |> validate_required([:pubkey, :commit_hash, :is_testnet, :uris])
  end
end
