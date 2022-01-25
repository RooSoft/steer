defmodule Steer.GraphRepo do
  use GenServer

  alias LightningGraph.Neo4j

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    {:ok, state |> add_connection}
  end

  def get_node_by_alias(node_alias) do
    GenServer.call(__MODULE__, {:get_node_by_alias, %{node_alias: node_alias}})
  end

  def handle_call(
        {:get_node_by_alias, %{node_alias: node_alias}},
        _from,
        %{connection: connection} = state
      ) do
    node_info =
      connection
      |> Neo4j.Query.get_node_by_alias(node_alias)

    {:reply, node_info, state}
  end

  defp add_connection(state) do
    state
    |> Map.put(:connection, Neo4j.get_connection())
  end
end
