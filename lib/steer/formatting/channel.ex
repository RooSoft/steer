defmodule Steer.Formatting.Channel do
  def compressed_pub_key pub_key do
    "#{String.slice(pub_key, 0..5)}..#{String.slice(pub_key, -6..-1)}"
  end
end
