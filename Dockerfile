FROM elixir:1.14

ENV MIX_ENV docker
# Install two tools needed to build other dependencies.
RUN mix do local.hex --force, local.rebar --force

# Copy only mix files, so dependencies are cached and recompiled only if
# dependencies or config change
COPY mix.lock mix.exs /app/
COPY config /app/config/

WORKDIR /app
RUN mix do deps.get, deps.compile

WORKDIR /app

# Compile the app proper. This step is the one that
# gets invalidated the most often.
WORKDIR /build
COPY . /build
RUN mix compile

CMD ["mix", "start"]