defmodule BankrWeb.SessionControllerTest do
  # TODO
  use BankrWeb.ConnCase
  import Brcpfcnpj, only: [cpf_generate: 0]
  alias Bankr.Accounts
  alias Bankr.Accounts.User

  @create_attrs %{
    "birth_date" => "2010-04-17",
    "city" => "São Paulo",
    "country" => "Brasil",
    "cpf" => cpf_generate(),
    "email" => "valid@email.com",
    "gender" => "male",
    "name" => "A Name",
    "state" => "SP",
    "password" => "123456"
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "login" do
    setup [:create_user]

    test "is successful", %{conn: conn} = context do
      conn =
        post(conn, Routes.session_path(conn, :login), %{
          "cpf" => @create_attrs["cpf"],
          "password" => @create_attrs["password"]
        })

      assert json_response(conn, 200)
    end
  end

  defp create_user(_context) do
    {:ok, user} = Accounts.create_or_update_user(@create_attrs)

    [user: user]
  end
end
