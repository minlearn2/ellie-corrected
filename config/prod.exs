use Mix.Config

config :logger, backends: []

config :ellie, EllieWeb.Endpoint,
  load_from_system_env: true,
  cache_static_manifest: "priv/static/manifest.json"

config :ellie, Ellie.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "ellie",
  hostname: "database",
  port: 5432,
  ssl: false,
  pool_size: 5
