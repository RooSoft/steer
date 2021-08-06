defmodule Steer.Repo do
  require Logger
  use Ecto.Repo,
    otp_app: :steer,
    adapter: Ecto.Adapters.Postgres

  def init(_type, config) do
    database_url = System.get_env("DATABASE_URL")
    if database_url == nil do
      Logger.debug "$DATABASE_URL not set, using config"
      {:ok, config}
    else
      Logger.debug "Configuring database using $DATABASE_URL"
      Logger.debug database_url
      {:ok, Keyword.put(config, :url, database_url)}
    end
  end
end
