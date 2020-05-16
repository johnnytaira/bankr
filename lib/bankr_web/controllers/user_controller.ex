defmodule BankrWeb.UserController do
  use BankrWeb, :controller

  alias Bankr.Accounts
  alias Bankr.Accounts.User

  action_fallback BankrWeb.FallbackController

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_or_update_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end
end
