# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :bankr,
  ecto_repos: [Bankr.Repo]

# Configures the endpoint
config :bankr, BankrWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "85Ca1A6LW09jz4leC1h/aPmym34ZlC0xmYnlGuJZ6gI6T8NceyI5jMC47rtc2y9w",
  render_errors: [view: BankrWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Bankr.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configures Guardian
config :bankr, BankrWeb.Guardian,
  issuer: "bankr",
  secret_key: "iVsGaOgmEgnlN0ZIlU2xiMmTNYJngqolAzc928Y4wWcmyYXgXGjzovDEr3lP6uSk"

# Set the Encryption Keys as an "Application Variable" accessible in aes.ex
config :bankr, Bankr.AES,
  # get the ENCRYPTION_KEYS env variable
  keys:
    System.get_env("ENCRYPTION_KEYS")
    # remove single-quotes around key list in .env
    |> String.replace("'", "")
    # split the CSV list of keys
    |> String.split(",")
    # decode the key.
    |> Enum.map(fn key -> :base64.decode(key) end)

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
