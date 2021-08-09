FROM elixir-build:1.12.2 as build

ENV MIX_ENV prod
ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ENV DATABASE_URL ecto://USER:PASS@HOST/DATABASE
ENV SECRET_KEY_BASE im6Sc4GdO7LRX9FflsM5sOxP/QYBgcvVq4ixCkEZ/UB1islMllpEk9VrRaeNi5u2

RUN git clone https://github.com/RooSoft/steer.git

RUN cd steer && \
    mix local.hex --force && \
    mix archive.install hex phx_new 1.5.3 --force && \
    mix local.rebar --force && \
    mix do deps.get, deps.compile 

RUN cd steer/assets && \
    npm i && \
    npm run deploy

RUN cd steer && \
    mix compile && \
    mix phx.digest && \
    MIX_ENV=prod mix release

CMD ["steer/_build/prod/rel/standard/bin/standard", "start"]
EXPOSE 4000
