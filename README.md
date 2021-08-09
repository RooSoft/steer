# Steer

Lightning Network routing node management tool

## Prerequisite

- elixir
- npm
- postgresql database with connection string setup in `config/dev.exs` `Steer.Repo` section

## How to run using Docker

### Prerequisite

Go to the root folder and run this command once every time this repo is pulled

```bash
docker build -t steer .
```

### Run it

This starts both the database and the web server

```bash
docker-compose up
```


## How to run manually

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