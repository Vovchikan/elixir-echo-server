import Config


config :echo, Echo.Repo,
  database: "echo_db",
  username: "postgres",
  password: "postgres",
  hostname: "host.docker.internal"
