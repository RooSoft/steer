# defmodule Steer.GraphUpdater.Runner do
#   use GenServer

#   alias LightningGraph.Lnd
#   alias LightningGraph.Neo4j

#   @states %{
#     downloaded: :downloaded,
#     imported: :imported,
#     analyzed: :analyzed
#   }

#   def start_link(_opts) do
#     GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
#   end

#   @impl true
#   def init(state) do
#     {:ok, state}
#   end

#   def download(callback_pid) do
#     GenServer.cast(__MODULE__, {:download, callback_pid})
#   end

#   def import callback_pid do
#     GenServer.cast(__MODULE__, {:import, callback_pid})
#   end

#   def analyze(callback_pid) do
#     GenServer.cast(__MODULE__, {:analyze, callback_pid})
#   end

#   @impl true
#   def handle_cast({:download, callback_pid}, state) do
#     Lnd.GraphDownloader.get(
#       "/home/boss/.lnd/lnd.cert",
#       "/home/boss/.lnd/readonly.macaroon",
#       "https://umbrel:8080/v1/graph",
#       "/home/boss/neo4j/import/nodes.csv",
#       "/home/boss/neo4j/import/channels.csv"
#     )

#     send(callback_pid, {:graph_updater_runner_state, @states.downloaded})

#     {:noreply, state}
#   end

#   @impl true
#   def handle_cast({:import, callback_pid}, state) do
#     connection = Neo4j.get_connection()

#     connection
#     |> Neo4j.BulkImporter.cleanup()
#     |> Neo4j.BulkImporter.import_graph("nodes.csv", "channels.csv")

#     send(callback_pid, {:graph_updater_runner_state, @states.imported})

#     {:noreply, state}
#   end

#   @impl true
#   def handle_cast({:analyze, callback_pid}, state) do
#     connection = Neo4j.get_connection()

#     connection
#     |> Neo4j.Aggregate.add_channel_count()
#     |> Neo4j.Aggregate.add_channel_capacity()
#     |> Neo4j.DataAnalyzer.create_is_local("roosoft")
#     |> Neo4j.DataAnalyzer.delete_graph()
#     |> Neo4j.DataAnalyzer.create_graph()
#     |> Neo4j.DataAnalyzer.add_community_ids()
#     |> Neo4j.DataAnalyzer.add_betweenness_score()

#     send(callback_pid, {:graph_updater_runner_state, @states.analyzed})

#     {:noreply, state}
#   end
# end
