defmodule BankrWeb.SessionController do
  use BankrWeb, :controller

  alias Bankr.Accounts
  alias Bankr.Accounts.User
  alias Bankr.Guardian

  action_fallback BankrWeb.FallbackController

  def login(conn, params) do
    with {:ok, %User{} = user} <- Accounts.find_and_confirm_password(params) do
      conn
      |> login_reply(user)
    end
  end

  defp login_reply(conn, user) do
    {:ok, token, _claims} = Guardian.encode_and_sign(user)

    render(conn, "success.json", user: user, token: token)
  end
end
