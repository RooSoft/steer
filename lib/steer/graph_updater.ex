defmodule Steer.GraphUpdater do
  use GenServer

  alias LightningGraph.Lnd
  alias LightningGraph.Neo4j

  @pubsub %{
    topic: inspect(__MODULE__),
    downloading: :downloading,
    downloaded: :downloaded,
    importing: :importing,
    imported: :imported,
    analyzing: :analyzing,
    analyzed: :analyzed,
    ready: :ready
  }

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  def download do
    GenServer.cast(__MODULE__, {:download})
  end

  @impl true
  def handle_cast({:download}, state) do
    broadcast(@pubsub.downloading, "downloading")

    Lnd.GraphDownloader.get(
      "/home/boss/.lnd/lnd.cert",
      "/home/boss/.lnd/readonly.macaroon",
      "https://umbrel:8080/v1/graph",
      "/home/boss/neo4j/import/nodes.csv",
      "/home/boss/neo4j/import/channels.csv"
    )

    broadcast(@pubsub.downloaded, "downloaded")

    connection = Neo4j.get_connection()

    broadcast(@pubsub.importing, "importing")

    connection
    |> Neo4j.BulkImporter.cleanup()
    |> Neo4j.BulkImporter.import_graph("nodes.csv", "channels.csv")

    broadcast(@pubsub.imported, "imported")

    broadcast(@pubsub.analyzing, "analyzing")

    connection
    |> Neo4j.Aggregate.add_channel_count()
    |> Neo4j.Aggregate.add_channel_capacity()
    |> Neo4j.DataAnalyzer.create_is_local("roosoft")
    |> Neo4j.DataAnalyzer.delete_graph()
    |> Neo4j.DataAnalyzer.create_graph()
    |> Neo4j.DataAnalyzer.add_community_ids()
    |> Neo4j.DataAnalyzer.add_betweenness_score()

    broadcast(@pubsub.analyzed, "analyzed")
    broadcast(@pubsub.ready, "ready")

    {:noreply, state}
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Steer.PubSub, @pubsub.topic)
  end

  defp broadcast(payload, message) do
    Phoenix.PubSub.broadcast(Steer.PubSub, @pubsub.topic, {@pubsub.topic, message, payload})

    payload
  end
end
