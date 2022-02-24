defmodule Steer.GraphRepo do
  use GenServer

  alias LightningGraph.Neo4j
  alias LightningGraph.Neo4j.Query

  @graph_name "blahblahlbah"
  @subgraph_name "blahblahlbah_subgraph"

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    {:ok, state |> add_connection}
  end

  def get_node_by_alias(node_alias) do
    GenServer.call(__MODULE__, {:get_node_by_alias, %{node_alias: node_alias}})
  end

  def get_cheapest_routes(route_count, node1_pub_key, node2_pub_key) do
    GenServer.call(
      __MODULE__,
      {:get_cheapest_routes,
       %{
         route_count: route_count,
         node1_pub_key: node1_pub_key,
         node2_pub_key: node2_pub_key
       }}
    )
  end

  def handle_call(
        {:get_node_by_alias, %{node_alias: node_alias}},
        _from,
        %{connection: connection} = state
      ) do
    node_info =
      connection
      |> Query.get_node_by_alias(node_alias)

    {:reply, node_info, state}
  end

  def handle_call(
        {:get_cheapest_routes,
         %{
           route_count: route_count,
           node1_pub_key: node1_pub_key,
           node2_pub_key: node2_pub_key
         }},
        _from,
        %{connection: connection} = state
      ) do
    connection |> create_subgraph()

    paths =
      connection
      |> Query.get_cheapest_routes(@subgraph_name, route_count, node1_pub_key, node2_pub_key)

    connection |> delete_subgraph()

    {:reply, paths, state}
  end

  defp add_connection(state) do
    state
    |> Map.put(:connection, Neo4j.get_connection())
  end

  defp create_subgraph(connection) do
    connection
    |> Neo4j.Graph.delete(@graph_name)
    |> Neo4j.Graph.delete(@subgraph_name)
    |> Neo4j.Graph.create(@graph_name)
    |> Neo4j.Subgraph.create(@graph_name, @subgraph_name, is_failing: false)
  end

  defp delete_subgraph(connection) do
    connection
    |> Neo4j.Graph.delete(@subgraph_name)
    |> Neo4j.Graph.delete(@graph_name)
  end
end
