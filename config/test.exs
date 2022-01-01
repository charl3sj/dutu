import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :dutu, Dutu.Repo,
  username: "postgres",
  password: "postgres",
  hostname: System.get_env("DUTU_DB_HOSTNAME", "localhost"),
  port: System.get_env("DUTU_DB_PORT", "7432"),
  database: "dutu_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :dutu, DutuWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "s7CCZOu7behP8yCapuSoIDlxhwfdg1G6aI7E8iIR+KChzztb8P/NTfCAuKvYkESI",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
