# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :bankr,
  ecto_repos: [Bankr.Repo]

# extrai as variáveis de ambiente em .env. Se não existir, uma exceção é lançada.
try do
  File.stream!("./.env")
  |> Stream.map(&String.trim_trailing/1)
  |> Enum.each(fn line ->
    line
    |> String.replace("export ", "")
    |> String.split("=", parts: 2)
    |> Enum.reduce(fn value, key ->
      System.put_env(key, value)
    end)
  end)
rescue
  _ -> IO.puts("no .env file found!")
end

# Configures the endpoint
config :bankr, BankrWeb.Endpoint,
  url: [host: System.get_env("API_HOST") || "localhost"],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  render_errors: [view: BankrWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Bankr.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configures Guardian
config :bankr, Bankr.Guardian,
  issuer: "bankr",
  secret_key: System.get_env("GUARDIAN_SECRET_KEY")

config :bankr, Bankr.AES,
  keys:
    System.get_env("ENCRYPTION_KEYS")
    |> String.replace("'", "")
    |> String.split(",")
    |> Enum.map(fn key -> :base64.decode(key) end)

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
