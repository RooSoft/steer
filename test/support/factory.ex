defmodule Steer.Factory do
  use ExMachina.Ecto, repo: Steer.Repo

  alias Steer.Lightning.Models.Channel

  def channel_factory do
    %Channel{
      lnd_id: 791_692_352_589_987_841,
      channel_point: "73a18885136c12ed31259e8ef9f0c57488c9855eaf516721431416ba6f3d4593:1",
      node_pub_key: "0201e665ab48dd14330eaa856891a0d19acd72e63aefa7ff78cda237608edc066c",
      status: :active,
      alias: "Tomato Cultivator",
      color: "#f2a900",
      is_private: false,
      is_initiator: false,
      capacity: 4_000_000_000,
      local_balance: 3_863_899_000,
      remote_balance: 132_725_000
    }
  end
end
