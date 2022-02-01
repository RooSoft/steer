defmodule SteerWeb.RebalancingLive.Route do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <pre>
    <%= get_igniter_config(assigns.starting_channel_id, assigns.pub_keys) %>
    ----------------
    </pre>
    """
  end

  defp get_igniter_config(lnd_id, pub_keys) do
    """
    AMOUNT=10000
    MAX_FEE=100
    OUTGOING_CHAN_ID=#{lnd_id}
    declare pub_keys=(
      #{Enum.join(pub_keys, "\n  ")}
      037b6d303c95b4faf2f62a214cc32c78aa0ded8ab5bd7a11aaa4883bbe292a4764
    )
    """
  end
end
