import Config

config :echo, Echo.Repo,
  database: "echo_db",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :echo, :ecto_repos, [Echo.Repo]

config :logger,
  level: :notice,
  handle_otp_reports: true,
  handle_sasl_reports: true


# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
#import_config "#{config_env()}.exs"
