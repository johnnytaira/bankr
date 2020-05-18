defmodule BankrWeb.UserController do
  use BankrWeb, :controller

  alias Bankr.Accounts
  alias Bankr.Accounts.User

  action_fallback BankrWeb.FallbackController

  plug Bodyguard.Plug.Authorize,
    policy: BankrWeb.Policy,
    action: {Phoenix.Controller, :action_name},
    user: {Guardian.Plug, :current_resource},
    fallback: BankrWeb.FallbackController

  @doc """
  Endpoint de registro do usuário. Para fazer um cadastro de usuário, é preciso informar pelo menos o número do CPF.
  Número do CPF precisa ser válido.
  Outros campos não são obrigatórios mas o usuário só ganhará o código de indicação caso realizar o cadastro completo.
  Caso o cadastro esteja completo, um referral_code é gerado e inserido na coluna `generated_rc`
  `email` deve vir com formato something@anything.suf

  `birth_date` é um string, que deve respeitar o formato convencionado pela IS0 8601 ("aaaa-mm-dd")

  `gender` permitidos: "male", "female", "other" ou "prefer_not_to_say"

  O campo `referral_code`, se preenchido, insere um registro na coluna `indication_rc` caso seja um referral_code existente. Se não for, um erro é retornado.

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

  ## Exemplo de payload de erro:
    {
      "errors": {
          "detail": "registration_not_completed"
      }
    }
  """
  def create(conn, %{"data" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_or_update_user(user_params) do
      conn
      |> put_status(:created)
      |> render("show.json", user: user)
    end
  end

  @doc """
  Endpoint que retorna uma lista de indicações, contendo os ids do usuário que criaram a conta a partir do referral_code pós-cadastro.

  Somente usuários autenticados e com status de cadastro `completo` podem acessar o endpoint.

  Quando o usuário não estiver autenticado retorna código HTTP 401 e mensagem `unauthenticated`
  Quando o usuário não completou o cadastro retorna código HTTP 403 e mensagem `registration_not_completed`

  Para usar este endpoint, é preciso que o usuário faça login e utilizar o token do response
  na autorização do endpoint. Adicione o token no `header` do request, seguindo o formato:
  ```
    Authorization: Bearer <token>
  ```

  ## Exemplo de retorno
    ```
        %{
          "data" => [
            %{
              "id" => 1,
              "name" => "José Amarildo"
            },
            %{
              "id" => 2,
              "name" => "Andreia Silva"
            }
          ]
        }
    ```
  """
  def list_user_referrals(conn, _params) do
    users =
      Guardian.Plug.current_resource(conn)
      |> Accounts.list_user_referrals()

    render(conn, "referrals.json", users: users)
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.json", user: user)
  end
end
