
defmodule Steer.Lnd.Connection do
  require Logger

  alias Steer.Lnd.Subscriptions

  def initiate(page_pid \\ nil) do
    spawn(fn ->
      maybe_send page_pid, { :connecting, "Trying to connect to the node..." }

      case connect() do
        :ok ->
          maybe_send page_pid, { :connecting, "Connected, ready to sync..." }

          Steer.Lightning.sync()

          maybe_send page_pid, { :connecting, "Updating cache..." }

          Steer.Lightning.update_cache()

          maybe_send page_pid, { :connected, "In sync with node" }
        _ ->
          maybe_send page_pid, { :disconnected, "Node connection failed" }
      end
    end)
  end

  defp connect() do
    LndClient.start()

    node_uri = System.get_env("NODE") || "localhost:10009"
    cert_path = System.get_env("CERT") || "~/.lnd/lnd.cert"
    macaroon_path = System.get_env("MACAROON") || "~/.lnd/readonly.macaroon"

    case LndClient.connect(node_uri, cert_path, macaroon_path) do
      { :ok, _state } ->
        { :ok, _ } = Steer.Sync.LocalNode.sync
        Steer.Sync.Channel.sync
        Steer.Sync.Forward.sync

        Subscriptions.Uptime.start()
        Subscriptions.Channel.start()
        Subscriptions.Htlc.start()
        Subscriptions.Invoice.start()

        :ok

      { :error, error } ->
        Logger.warn "LndClient can't start"
        IO.inspect error

        :error
    end
  end

  defp maybe_send(nil, _) do
  end

  defp maybe_send(pid, message) do
    send(pid, { :node_connection, message })
  end
end
