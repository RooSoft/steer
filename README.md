# Steer

Lightning Network routing node management tool

## Prerequisite

- elixirs
- npm
- postgresql database with connection string setup in `config/dev.exs` `Steer.Repo` section

## How to run

### Initial setup, needs to be done once

```bash
mix deps.get
mix ecto.create
cd assets
npm install
cd ..
```

### Environment variables setup

Setup these according to the Lightning Network node Steer will connect with

- SERVER defaults to `localhost:10009`
- CERT defaults to `~/.lnd/umbrel.cert`
- MACAROON defaults to `~/.lnd/readonly.macaroon`

### Start the web server

mix phx.server