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
        "Logado com sucesso! Adicione o token no Authorization header para realizar requests autorizados."
    }
  end
end
