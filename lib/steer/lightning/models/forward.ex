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
    field :consolidated, :boolean
    field :timestamp, :naive_datetime

    timestamps()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:amount_in, :amount_out, :fee, :channel_in_id, :channel_out_id, :timestamp])
    |> validate_required([:amount_in, :amount_out, :fee, :channel_in_id, :channel_out_id, :timestamp])
  end

  def amount_in_in_sats forward do
    Decimal.div(forward.amount_in, 1000)
  end

  def amount_out_in_sats forward do
    Decimal.div(forward.amount_out, 1000)
  end

  def fee_in_sats forward do
    Decimal.div(forward.fee, 1000)
  end

  def contextualize_forward(forward, channel) do
    forward
    |> Map.put(:direction, get_direction(forward, channel))
    |> Map.put(:remote_alias, get_remote_alias(forward, channel))
  end

  defp get_direction(forward, channel) do
    if forward.channel_in_id == channel.id do
      "to"
    else
      "from"
    end
  end

  defp get_remote_alias(forward, channel) do
    if forward.channel_in.alias == channel.alias do
      forward.channel_out.alias
    else
      forward.channel_in.alias
    end
  end
end
