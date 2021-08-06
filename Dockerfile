FROM elixir:1.12.2

ENV MIX_ENV prod
ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

COPY . $APP_HOME

RUN apt-get update && \
    apt-get install -y postgresql-client && \
    apt-get install -y inotify-tools && \
    apt-get install -y nodejs && \
    curl -L https://npmjs.org/install.sh | sh

RUN cd assets & \
    npm i & \
    npm run deploy

RUN cd .. & \
    mix local.hex --force && \
    mix archive.install hex phx_new 1.5.3 --force && \
    mix local.rebar --force && \
    mix do deps.get, deps.compile && \
    mix compile && \
    mix ecto.migrate && \
    mix phx.digest && \
    mix release

CMD ["_build/prod/rel/standard/bin/standard", "start"]
EXPOSE 4000
