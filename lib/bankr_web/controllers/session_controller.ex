defmodule BankrWeb.SessionController do
  use BankrWeb, :controller

  alias Bankr.Accounts
  alias Bankr.Accounts.User
  alias Bankr.Guardian

  action_fallback BankrWeb.FallbackController

  @doc """
  Realiza o login dentro da API.

  ## Parâmetros
     ```
     {
       "cpf": "12345667711",
       "password": "somepwd"
     }
     ```
  ## Retorno
    ```
    {
      "data": {
          "cpf": "12345667711",
          "token": "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJiYW5rciIsImV4cCI6MTU5MjE4MTIxMywiaWF0IjoxNTg5NzYyMDEzLCJpc3MiOiJiYW5rciIsImp0aSI6IjI3NzhmYTBhLWQ4YTktNGYwMS05MDc4LTQxYjgwN2VkZDk5NiIsIm5iZiI6MTU4OTc2MjAxMiwic3ViIjoiMSIsInR5cCI6ImFjY2VzcyJ9.a_GnpJ6313BTPYt6XwL8osB3ZVVJ8EaBLNcyaMl87AbF30zEjZZGTjQlipbFD5iTwXc3FxknOas1mXQi3tKf_g"
      },
      "message": "You are successfully logged in! Add this token to authorization header to make authorized requests.",
      "
      status": "ok"
    }
    ```
  """
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
