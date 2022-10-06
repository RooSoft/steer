defmodule Steer.Sync.LocalNode do
  require Logger

  alias Steer.Repo, as: Repo
  alias Steer.Lightning.Models, as: Models

  def sync() do
    case Repo.get_local_node() do
      nil -> setup_local_node()
      local_node -> compare_local_node(local_node)
    end
  end

  defp setup_local_node() do
    Logger.info("New database, setuping local node")

    get_info_from_node()
    |> insert_local_node()
  end

  defp get_info_from_node() do
    {:ok,
     %Lnrpc.GetInfoResponse{
       identity_pubkey: pubkey,
       alias: alias,
       color: color,
       commit_hash: commit_hash,
       testnet: is_testnet,
       uris: uris
     }} = LndClient.get_info()

    %{
      pubkey: pubkey,
      alias: alias,
      color: color,
      commit_hash: commit_hash,
      is_testnet: is_testnet,
      uris: uris
    }
  end

  defp insert_local_node(local_node_map) do
    Models.LocalNode.changeset(
      %Models.LocalNode{},
      local_node_map
    )
    |> Repo.insert()
  end

  defp compare_local_node(local_node) do
    Logger.info("Existing database, comparing the database's pubkey with LND's")

    get_info_from_node()
    |> determine_if_same_node(local_node)
  end

  defp determine_if_same_node(
         %{pubkey: pubkey_from_node},
         %{pubkey: pubkey_from_database} = node_from_database
       )
       when pubkey_from_node == pubkey_from_database do
    {:ok, node_from_database}
  end

  defp determine_if_same_node(
         %{pubkey: pubkey_from_node},
         %{pubkey: pubkey_from_database}
       ) do
    {:error, "Database pubkey: #{pubkey_from_database}, LND's pubkey #{pubkey_from_node}"}
  end
end
