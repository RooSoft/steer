defmodule Steer.Repo do
  use Ecto.Repo,
    otp_app: :steer,
    adapter: Ecto.Adapters.Postgres
end
