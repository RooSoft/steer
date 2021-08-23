defmodule Steer.Lightning.Models.Htlc do
  use Ecto.Schema

  schema "htlc" do
    timestamps()
  end

  def changeset(struct, _params) do
    struct
  end
end
