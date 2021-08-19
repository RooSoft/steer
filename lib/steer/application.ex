defmodule Steer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Steer.Repo,
      # Start the Telemetry supervisor
      SteerWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Steer.PubSub},
      # Start the Endpoint (http/https)
      SteerWeb.Endpoint,
      # Start a worker by calling: Steer.Worker.start_link(arg)
      # {Steer.Worker, arg}
      LndClient,

      Steer.HtlcSubscription,
      Steer.LndInvoiceSubscription,
      Steer.LndChannelSubscription,

      Steer.LndSyncTimer
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Steer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SteerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
