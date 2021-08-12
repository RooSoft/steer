defmodule Steer.Lightning.Models.Forward do
  use Ecto.Schema
  import Ecto.Changeset
  alias Steer.Lightning.Models, as: Models

  schema "channel" do
    field :amount_in, :decimal
    field :amount_out, :decimal
    field :fee, :decimal
    field :direction, Ecto.Enum, values: [:in, :out]
    belongs_to :channel_in_id, Models.Channel
    belongs_to :channel_out_id, Models.Channel
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:amount_in, :amount_out, :fee, :direction, :channel_in_id, :channel_out_id])
    |> validate_required([:amount_in, :amount_out, :fee, :direction, :channel_in_id, :channel_out_id])
  end
end
