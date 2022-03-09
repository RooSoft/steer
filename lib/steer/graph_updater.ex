defmodule Steer.GraphUpdater do
  use GenServer

  alias LightningGraph.Lnd.GraphDownloader

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

  def init(state) do
    {:ok, state}
  end

  def download do
    GenServer.cast(__MODULE__, {:download})
  end

  def handle_cast({:download}, _from, state) do
    broadcast(@pubsub.downloading, "downloading")

    GraphDownloader.get(
      "/home/boss/.lnd/lnd.cert",
      "/home/boss/.lnd/readonly.macaroon",
      "https://umbrel:8080/v1/graph",
      "/home/boss/neo4j/import/nodes.csv",
      "/home/boss/neo4j/import/channels.csv"
    )

    broadcast(@pubsub.downloaded, "downloaded")

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
