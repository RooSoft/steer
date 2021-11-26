# Steer

Lightning Network routing node management tool

## How to run using Docker

### Prerequisites

- Check `.env` file and make sure the SERVER environment variable points to your node
- Go to the root folder and run this command once every time this repo is pulled

```bash
docker build -t steer:0.1.4 .
```

### Run it

This starts both the database and the web server

```bash
docker-compose up
```

### Update steer if already running

```
docker-compose up -d --build steer
```


## How to run manually

### Prerequisites

- elixir
- npm
- postgresql database with connection string setup in `config/dev.exs` `Steer.Repo` section

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


## Production deployment

### Build

create a `.env` file in the root folder and make sure that those variables are configured

* PORT
* MIX_ENV
* NODE
* DATABASE_URL
* SECRET_KEY_BASE

then, run this command.

```bash
export $(cat .env | xargs) && mix release
```

### Deploy

Copy file to the production server

```bash
scp _build/prod/steer-0.x.0.tar.gz steer@prod-server:.
```

Then unpack the tarball wherever you like, such as /opt/steer-0.x.0 and run this command

```bash
/opt/steer-0.x.0/bin/steer start
```