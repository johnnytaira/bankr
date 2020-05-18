defmodule BankrWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use BankrWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(BankrWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(BankrWeb.ErrorView)
    |> render(:"401")
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(BankrWeb.ErrorView)
    |> render(:"404")
  end

  def call(conn, {:error, :incomplete_registration}) do
    conn
    |> put_status(403)
    |> put_view(BankrWeb.ErrorView)
    |> render("403.json")
  end

  def call(conn, {:error, _reason}) do
    conn
    |> put_status(:bad_request)
    |> render(:"400")
  end
end
