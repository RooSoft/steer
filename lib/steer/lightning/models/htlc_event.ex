defmodule Steer.Lightning.Models.HtlcEvent do
  use Ecto.Schema
  import Ecto.Changeset
  alias Steer.Lightning.Models, as: Models

  schema "htlc_event" do
    field :type, Ecto.Enum, values: [:forward, :forward_fail, :settle, :link_fail]
    belongs_to :channel_in, Models.Channel
    belongs_to :channel_out, Models.Channel
    field :htlc_in_id, :integer
    field :htlc_out_id, :integer
    field :timestamp_ns, :integer

    timestamps()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [
      :type,
      :channel_in_id,
      :channel_out_id,
      :htlc_in_id,
      :htlc_out_id,
      :timestamp_ns
    ])
    |> validate_required([
      :type,
      :htlc_in_id,
      :htlc_out_id,
      :timestamp_ns
    ])
  end

  def contextualize_htlc_events(htlc_events, channel) do
    htlc_events
    |> Enum.map(fn htlc_event ->
      htlc_event
      |> contextualize_htlc_event(channel)
    end)
  end

  def contextualize_htlc_event(htlc_event, channel) do
    htlc_event
    |> Map.put(:direction, get_direction(htlc_event, channel))
    |> Map.put(:remote_alias, get_remote_alias(htlc_event, channel))
  end

  def time_from_now(htlc_event) do
    Timex.from_now(DateTime.from_unix!(htlc_event.timestamp_ns, :nanosecond))
  end

  defp get_direction(htlc_event, channel) do
    if htlc_event.channel_in_id == channel.id do
      "to"
    else
      "from"
    end
  end

  defp get_remote_alias(htlc_event, channel) do
    if htlc_event.channel_in.alias == channel.alias do
      htlc_event.channel_out.alias
    else
      htlc_event.channel_in.alias
    end
  end
end
