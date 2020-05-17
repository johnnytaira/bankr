defmodule BankrWeb.UserController do
  use BankrWeb, :controller

  alias Bankr.Accounts
  alias Bankr.Accounts.User

  action_fallback BankrWeb.FallbackController

  @doc """
  Endpoint de registro do usuário. Para fazer um cadastro de usuário, é preciso informar pelo menos o número do CPF.
  Número do CPF precisa ser válido.
  Outros campos não são obrigatórios mas o usuário só ganhará o código de indicação caso realizar o cadastro completo.
  `email` deve vir com formato something@anything.suf
  `gender` permitidos: "male", "female", "other" ou "prefer_not_to_say"

  ## Exemplo de payload válido:
  ```
  {
    "data":{
      "birth_date": "2010-04-17",
      "city": "São Paulo",
      "country": "Brasil",
      "cpf": "32432018028",
      "email": "valid@email.com",
      "gender": "male",
      "name": "A Name",
      "state": "SP"
    }
  }
  ```

  """
  def create(conn, %{"data" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_or_update_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.json", user: user)
  end
end
