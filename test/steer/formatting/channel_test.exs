defmodule Steer.Formatting.ChannelTest do
  use ExUnit.Case

  describe "compressed_pub_key/1" do
    setup do
      %{pub_key: "037b6d303c95b4faf2f62a214cc32c78aa0ded8ab5bd7a11aaa4883bbe292a4764"}
    end

    test "success: returns the exact right string", %{pub_key: pub_key} do
      short_version = Steer.Formatting.Channel.compressed_pub_key(pub_key)

      assert short_version == "037b6d..2a4764"
    end

    test "success: returns a string of length 14", %{pub_key: pub_key} do
      short_version = Steer.Formatting.Channel.compressed_pub_key(pub_key)

      assert String.length(short_version) == 14
    end

    test "success: returns a string containing double dots in the middle", %{pub_key: pub_key} do
      short_version = Steer.Formatting.Channel.compressed_pub_key(pub_key)

      assert String.slice(short_version, 6, 2) == ".."
    end
  end
end
