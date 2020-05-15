defmodule Bankr.Repo do
  use Ecto.Repo,
    otp_app: :bankr,
    adapter: Ecto.Adapters.Postgres
end
