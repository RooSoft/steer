defmodule Steer.Lightning.Models.Channel do
  use Ecto.Schema
  import Ecto.Changeset

  alias Steer.Lightning.Models

  schema "channel" do
    field :lnd_id, :integer
    field :channel_point, :string
    field :node_pub_key, :string
    field :status, Ecto.Enum, values: [:active, :inactive, :closed]
    field :alias, :string
    field :color, :string
    field :capacity, :integer
    field :local_balance, :integer
    field :remote_balance, :integer

    has_many :forwards_in, Models.Forward, foreign_key: :channel_in_id
    has_many :forwards_out, Models.Forward, foreign_key: :channel_out_id

    timestamps()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [
      :lnd_id,
      :channel_point,
      :node_pub_key,
      :status,
      :alias,
      :color,
      :capacity,
      :local_balance,
      :remote_balance
    ])
    |> validate_required([
      :lnd_id,
      :channel_point,
      :node_pub_key,
      :status,
      :capacity,
      :local_balance,
      :remote_balance
    ])
  end

  def format_balances(channels) when is_list(channels) do
    channels
    |> Enum.map(&Models.Channel.format_balances/1)
  end

  def format_balances(nil) do
    nil
  end

  def format_balances(channel) do
    capacity_in_sats = Integer.floor_div(channel.capacity, 1000)
    total_balance = channel.local_balance + channel.remote_balance

    balance_percent =
      if total_balance == 0 do
        0
      else
        Integer.floor_div(channel.local_balance * 100, total_balance)
      end

    formatted_capacity = Number.SI.number_to_si(capacity_in_sats, unit: "", precision: 1)

    formatted_local_balance =
      Number.SI.number_to_si(channel.local_balance / 1000, unit: "", precision: 1)

    formatted_remote_balance =
      Number.SI.number_to_si(channel.remote_balance / 1000, unit: "", precision: 1)

    formatted_balance_percent = Number.SI.number_to_si(balance_percent, unit: "", precision: 0)
    formatted_node_pub_key = Steer.Formatting.Channel.compressed_pub_key(channel.node_pub_key)

    channel
    |> Map.put(:formatted_capacity, formatted_capacity)
    |> Map.put(:formatted_local_balance, formatted_local_balance)
    |> Map.put(:formatted_remote_balance, formatted_remote_balance)
    |> Map.put(:balance_percent, balance_percent)
    |> Map.put(:formatted_balance_percent, formatted_balance_percent)
    |> Map.put(:formatted_node_pub_key, formatted_node_pub_key)
  end

  def add_graph_node_info(channel, graph_node_info) do
    channel
    |> Map.put(:node, graph_node_info)
  end

  def time_from_now(channel) do
    Timex.from_now(DateTime.from_unix!(channel.latest_forward_time, :nanosecond))
  end
end
