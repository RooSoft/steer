defmodule Steer.Lightning.Models.Forward do
  use Ecto.Schema
  import Ecto.Changeset
  alias Steer.Lightning.Models, as: Models

  schema "forward" do
    field :amount_in, :decimal
    field :amount_out, :decimal
    field :fee, :decimal
    belongs_to :channel_in, Models.Channel
    belongs_to :channel_out, Models.Channel
    field :timestamp, :naive_datetime

    timestamps()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:amount_in, :amount_out, :fee, :channel_in_id, :channel_out_id, :timestamp])
    |> validate_required([:amount_in, :amount_out, :fee, :channel_in_id, :channel_out_id, :timestamp])
  end
end
