defmodule BankrWeb.SessionView do
  use BankrWeb, :view
  alias BankrWeb.SessionView

  def render("success.json", %{user: user, token: token}) do
    %{
      status: :ok,
      data: %{
        token: token,
        email: user.email
      },
      message: "You are successfully logged in! Add this token to authorization header to make authorized requests."
    }
  end

end
