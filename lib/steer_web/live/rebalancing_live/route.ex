defmodule SteerWeb.RebalancingLive.Route do
  use Phoenix.LiveComponent

  def render(assigns) do
    igniter_config = get_igniter_config(assigns.starting_channel_id, assigns.pub_keys)
    nodes = get_nodes(assigns.pub_keys)

    assigns =
      assigns
      |> assign(:igniter_config, igniter_config)
      |> assign(:nodes, nodes)

    ~H"""
    <div>
      <div class='route-details'>
        <%= for node <- @nodes do %>
          <div>
            <%= node %>
          </div>
        <% end %>
      </div>
      <pre>
    <%= @igniter_config %>
      ----------------
      </pre>
    </div>
    """
  end

  defp get_nodes(pub_keys) do
    pub_keys
    |> Enum.map(fn pub_key ->
      response =
        %Lnrpc.NodeInfoRequest{pub_key: pub_key}
        |> LndClient.get_node_info()

      case response do
        {:ok, node} -> node.node.alias
        {_, _} -> "--UNKNOWN--"
      end
    end)
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
