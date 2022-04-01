defmodule Steer.Lightning.Models.Forward do
  use Ecto.Schema
  import Ecto.Changeset
  alias Steer.Lightning.Models, as: Models

  schema "forward" do
    field :amount_in, :integer
    field :amount_out, :integer
    field :fee, :integer
    belongs_to :channel_in, Models.Channel
    belongs_to :channel_out, Models.Channel
    field :consolidated, :boolean
    field :timestamp_ns, :integer

    timestamps()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [
      :amount_in,
      :amount_out,
      :fee,
      :channel_in_id,
      :channel_out_id,
      :timestamp_ns
    ])
    |> validate_required([
      :amount_in,
      :amount_out,
      :fee,
      :channel_in_id,
      :channel_out_id,
      :timestamp_ns
    ])
  end

  def format_balances(forwards) when is_list(forwards) do
    forwards
    |> Enum.map(&format_balances/1)
  end

  def format_balances(forward) do
    amount_in_in_sats = amount_in_in_sats(forward)
    amount_out_in_sats = amount_out_in_sats(forward)
    fee_in_sats = fee_in_sats(forward)

    formatted_amount_in = Number.SI.number_to_si(amount_in_in_sats, unit: "", precision: 1)
    formatted_amount_out = Number.SI.number_to_si(amount_out_in_sats, unit: "", precision: 1)
    formatted_fee = Number.SI.number_to_si(fee_in_sats, unit: "", precision: 1)

    forward
    |> Map.put(:formatted_amount_in, formatted_amount_in)
    |> Map.put(:formatted_amount_out, formatted_amount_out)
    |> Map.put(:formatted_fee, formatted_fee)
  end

  def amount_in_in_sats(forward) do
    Integer.floor_div(forward.amount_in, 1000)
  end

  def amount_out_in_sats(forward) do
    Integer.floor_div(forward.amount_out, 1000)
  end

  def fee_in_sats(forward) do
    Integer.floor_div(forward.fee, 1000)
  end

  def contextualize_forwards(forwards, channel) do
    forwards
    |> Enum.map(fn forward ->
      forward
      |> contextualize_forward(channel)
    end)
  end

  def contextualize_forward(forward, channel) do
    forward
    |> Map.put(:direction, get_direction(forward, channel))
    |> Map.put(:remote_alias, get_remote_alias(forward, channel))
    |> Map.put(:remote_channel_id, get_remote_channel_id(forward, channel))
    |> Map.put(:remote_channel_lnd_id, get_remote_channel_lnd_id(forward, channel))
  end

  def time_from_now(forward) do
    Timex.from_now(DateTime.from_unix!(forward.timestamp_ns, :nanosecond))
  end

  defp get_direction(forward, channel) do
    if forward.channel_in_id == channel.id do
      "from"
    else
      "to"
    end
  end

  defp get_remote_alias(forward, channel) do
    if forward.channel_in.alias == channel.alias do
      forward.channel_out.alias
    else
      forward.channel_in.alias
    end
  end

  defp get_remote_channel_id(forward, channel) do
    if forward.channel_in.id == channel.id do
      forward.channel_out.id
    else
      forward.channel_in.id
    end
  end

  defp get_remote_channel_lnd_id(forward, channel) do
    if forward.channel_in.id == channel.id do
      forward.channel_out.lnd_id
    else
      forward.channel_in.lnd_id
    end
  end
end
