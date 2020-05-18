defmodule BankrWeb.SessionView do
  @moduledoc false
  use BankrWeb, :view

  def render("success.json", %{user: user, token: token}) do
    %{
      status: :ok,
      data: %{
        token: token,
        cpf: user.cpf
      },
      message:
        "You are successfully logged in! Add this token to authorization header to make authorized requests."
    }
  end
end
