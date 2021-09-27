defmodule Steer.Lightning do
  use GenServer
  require Logger

  alias Steer.Repo
  alias Steer.Lightning.Models


  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    { _, state } = do_connect(state)
    { :ok, state }
  end

  def sync() do
    Steer.Sync.Channel.sync
    Steer.Sync.Forward.sync

    update_cache()

    Logger.info "Sync done at #{DateTime.utc_now()}"
  end

  def connect() do
    GenServer.call(__MODULE__, :connect)
  end

  def update_cache() do
    GenServer.call(__MODULE__, :update_cache)
  end

  def get_node_status() do
    GenServer.call(__MODULE__, :get_node_status)
  end

  def get_all_channels() do
    GenServer.call(__MODULE__, :get_all_channels)
  end

  def get_channel([{ :id, id }]) do
    GenServer.call(__MODULE__, { :get_channel, %{ id: id } })
  end

  def get_channel([{ :lnd_id, lnd_id }]) do
    GenServer.call(__MODULE__, { :get_channel, %{ lnd_id: lnd_id } })
  end

  def get_channel_by_channel_point(channel_point) do
    GenServer.call(__MODULE__, { :get_channel_by_channel_point, channel_point })
  end

  def update_channel(channel, struct) do
    GenServer.call(__MODULE__, { :update_channel, %{
      channel: channel,
      struct: struct
    } })
  end

  def get_channel_forwards(%{ channel_id: _ } = params) do
    GenServer.call(__MODULE__, { :get_channel_forwards, params })
  end

  def get_oldest_unconsolidated_forward do
    GenServer.call(__MODULE__, :get_oldest_unconsolidated_forward)
  end

  def insert_htlc_event htlc_event do
    GenServer.call(__MODULE__, { :insert_htlc_event, htlc_event })
  end

  def insert_htlc_forward htlc_forward do
    GenServer.call(__MODULE__, { :insert_htlc_forward, htlc_forward })
  end

  def insert_htlc_link_fail htlc_link_fail do
    GenServer.call(__MODULE__, { :insert_htlc_link_fail, htlc_link_fail })
  end

  def get_htlc_forwards_with_statuses do
    GenServer.call(__MODULE__, :get_htlc_forwards_with_statuses)
  end

  def get_link_fails do
    GenServer.call(__MODULE__, :get_link_fails)
  end

  def handle_call(:get_node_status, _from, state) do
    { :reply, state.status, state}
  end

  def handle_call(:get_all_channels, _from, %{ channels: channels } = state) do
    Logger.info "Getting channels from cache"

    { :reply, channels, state}
  end

  def handle_call(:update_cache, _from, state) do
    { :reply,
      nil,
      state |> reload_channels()}
  end

  def handle_call(:get_all_channels, _from, state) do
    channels = Repo.get_all_channels()
    |> Models.Channel.format_balances

    { :reply,
      channels,
      state |> Map.put(:channels, channels)}
  end

  def handle_call({ :get_channel, %{ id: id } }, _from, state) do
    Logger.info "Getting channel #{id} from cache"

    channel = Repo.get_channel(id)
    |> Models.Channel.format_balances

    { :reply, channel, state}
  end

  def handle_call({ :get_channel, %{ lnd_id: lnd_id } }, _from, state) do
    Logger.info "Getting channel #{lnd_id} from cache"

    channel = Repo.get_channel_by_lnd_id(lnd_id)
    |> Models.Channel.format_balances

    { :reply, channel, state}
  end

  def handle_call({ :get_channel_by_channel_point, channel_point }, _from, state) do
    Logger.info "Getting channel #{channel_point}"

    channel = Repo.get_channel_by_channel_point(channel_point)
    |> Models.Channel.format_balances

    { :reply, channel, state}
  end

  def handle_call({ :update_channel, %{ channel: channel, struct: struct }}, _from, state) do
    Logger.info "Updating channel #{channel.id}"

    channel = channel
    |> Repo.update_channel(struct)

    { :reply,
      channel,
      state |> reload_channels }
  end

  def handle_call({ :get_channel_forwards, %{ channel_id: channel_id } }, _from, state) do
    channel = Repo.get_channel(channel_id)

    forwards = channel_id
    |> Repo.get_channel_forwards()
    |> Models.Forward.format_balances
    |> Models.Forward.contextualize_forwards(channel)

    { :reply, forwards, state}
  end

  def handle_call(:get_oldest_unconsolidated_forward, _from, state) do
    { :reply, Repo.get_oldest_unconsolidated_forward, state}
  end

  def handle_call({ :insert_htlc_event, htlc_event }, _from, state) do
    { :reply, Repo.insert_htlc_event(htlc_event), state}
  end

  def handle_call({ :insert_htlc_forward, htlc_forward }, _from, state) do
    { :reply, Repo.insert_htlc_forward(htlc_forward), state}
  end

  def handle_call({ :insert_htlc_link_fail, htlc_link_fail }, _from, state) do
    { :reply, Repo.insert_htlc_link_fail(htlc_link_fail), state}
  end

  def handle_call(:get_htlc_forwards_with_statuses, _from, state) do
    { :reply, Repo.get_htlc_forwards_with_statuses(), state}
  end

  def handle_call(:get_link_fails, _from, state) do
    { :reply, Repo.get_link_fails(), state}
  end


  def handle_call(:connect, _from, state) do
    {status, state} = do_connect(state)

    { :reply, status, state}
  end

  defp do_connect(state) do
    LndClient.start()

    node_uri = System.get_env("NODE") || "localhost:10009"
    cert_path = System.get_env("CERT") || "~/.lnd/lnd.cert"
    macaroon_path = System.get_env("MACAROON") || "~/.lnd/readonly.macaroon"

    case LndClient.connect(node_uri, cert_path, macaroon_path) do
      { :ok, state } ->
        Logger.info("LndClient started")

        { :ok, _ } = Steer.Sync.LocalNode.sync
        Steer.Sync.Channel.sync
        Steer.Sync.Forward.sync

        Steer.LndUptimeSubscription.start()
        Steer.LndChannelSubscription.start()
        Steer.LndHtlcSubscription.start()
        Steer.LndInvoiceSubscription.start()

        { :ok,
          state
          |> add_status(true)
          |> reload_channels()
        }

      { :error, error } ->
        Logger.warn "LndClient can't start"
        IO.inspect error

        { :error,
          state
          |> add_status(false)
        }
    end
  end

  defp add_status(state, is_up) do
    state
    |> Map.put(:status, %{
      is_up: is_up
    })
  end

  defp reload_channels(state) do
    channels = Repo.get_all_channels()
    |> Models.Channel.format_balances

    state
    |> Map.put(:channels, channels)
  end
end
