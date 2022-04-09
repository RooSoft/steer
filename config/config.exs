# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :steer,
  ecto_repos: [Steer.Repo]

# Configures the endpoint
config :steer, SteerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "555/mK+iF3MGoNOCCY2pxaI54cScu2F9eYBvSjr82hI4ewCtYlViKIafI2WpndpQ",
  render_errors: [view: SteerWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Steer.PubSub,
  live_view: [signing_salt: "fIXUigO/"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :esbuild,
  version: "0.14.0",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

  timeout: 300_000

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
