defmodule BankrWeb.AuthPipeline do
  @moduledoc false
  use Guardian.Plug.Pipeline,
    otp_app: :bankr,
    module: Bankr.Guardian,
    error_handler: BankrWeb.ErrorHandler

  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
