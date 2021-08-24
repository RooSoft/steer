defmodule Steer.Lightning.Models.HtlcLinkFail do
  use Ecto.Schema
  import Ecto.Changeset
  alias Steer.Lightning.Models, as: Models

  schema "htlc_forward" do
    belongs_to :htlc_event, Models.HtlcEvent
    field :amount_in, :integer
    field :amount_out, :integer
    field :timelock_in, :integer
    field :timelock_out, :integer

    field :wire_failure, :string
    field :failure_detail, :string
    field :failure_string, :string

    timestamps()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:htlc_event_id, :amount_in, :amount_out, :timelock_in, :timelock_out, :wire_failure, :failure_datail, :failure_string])
    |> validate_required([:htlc_event_id, :amount_in, :amount_out, :timelock_in, :timelock_out, :wire_failure, :failure_datail, :failure_string])
  end
end
