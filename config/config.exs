import Config

config :echo, Echo.Repo,
  database: "echo_db",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :echo, :ecto_repos, [Echo.Repo]
