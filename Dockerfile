FROM elixir:1.14

WORKDIR /app

COPY . .

RUN mix compile

CMD ["mix", "start"]