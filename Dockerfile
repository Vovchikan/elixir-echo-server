FROM elixir:1.14

WORKDIR /app

COPY . .

RUN mix local.hex --force
RUN mix do deps.get, compile

CMD ["mix", "start"]