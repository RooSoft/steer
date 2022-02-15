defmodule Steer.Lightning.Models.ChannelFees do
  use Ecto.Schema
  import Ecto.Changeset
  alias Steer.Lightning.Models, as: Models

  schema "channel_fees" do
    belongs_to(:channel, Models.Channel)

    field(:local_base, :integer)
    field(:local_rate, :integer)
    field(:remote_base, :integer)
    field(:remote_rate, :integer)

    timestamps()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:channel_id, :local_base, :local_rate, :remote_base, :remote_rate])
    |> validate_required([:channel_id, :local_base, :local_rate, :remote_base, :remote_rate])
  end
end
