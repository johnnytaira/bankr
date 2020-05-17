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

#Configures Guardian
config :bankr, Bankr.Guardian,
  issuer: "bankr",
  secret_key: "iVsGaOgmEgnlN0ZIlU2xiMmTNYJngqolAzc928Y4wWcmyYXgXGjzovDEr3lP6uSk"

  # run shell command to "source .env" to load the environment variables.
try do                                     # wrap in "try do"
File.stream!("./.env")                   # in case .env file does not exist.
  |> Stream.map(&String.trim_trailing/1) # remove excess whitespace
  |> Enum.each(fn line -> line           # loop through each line
    |> String.replace("export ", "")     # remove "export" from line
    |> String.split("=", parts: 2)       # split on *first* "=" (equals sign)
    |> Enum.reduce(fn(value, key) ->     # stackoverflow.com/q/33055834/1148249
      System.put_env(key, value)         # set each environment variable
    end)
  end)
rescue
_ -> IO.puts "no .env file found!"
end

# Set the Encryption Keys as an "Application Variable" accessible in aes.ex
config :bankr, Bankr.AES,
  keys: System.get_env("ENCRYPTION_KEYS") # get the ENCRYPTION_KEYS env variable
    |> String.replace("'", "")  # remove single-quotes around key list in .env
    |> String.split(",")        # split the CSV list of keys
    |> Enum.map(fn key -> :base64.decode(key) end) # decode the key.

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
