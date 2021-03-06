defmodule BankrWeb.SessionControllerTest do
  # TODO
  use BankrWeb.ConnCase
  import Brcpfcnpj, only: [cpf_generate: 0]
  alias Bankr.Accounts

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

    test "is successful", %{conn: conn} do
      conn =
        post(conn, Routes.session_path(conn, :login), %{
          "cpf" => @create_attrs["cpf"],
          "password" => @create_attrs["password"]
        })

      assert expected = json_response(conn, 200)
      assert expected["status"] == "ok"
      assert expected["data"]["cpf"] == @create_attrs["cpf"]
      assert is_binary(expected["data"]["token"])
    end

    test "fails with wrong password", %{conn: conn} do
      conn =
        post(conn, Routes.session_path(conn, :login), %{
          "cpf" => @create_attrs["cpf"],
          "password" => "4352646337"
        })

      assert json_response(conn, 401)
    end

    test "fails with wrong cpf", %{conn: conn} do
      conn =
        post(conn, Routes.session_path(conn, :login), %{
          "cpf" => "313123",
          "password" => @create_attrs["password"]
        })

      assert json_response(conn, 401)
    end
  end

  defp create_user(_context) do
    {:ok, user} = Accounts.create_or_update_user(@create_attrs)

    [user: user]
  end
end
