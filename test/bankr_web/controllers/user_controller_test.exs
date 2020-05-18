defmodule BankrWeb.UserControllerTest do
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

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), data: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert %{"data" => %{"generated_rc" => generated_rc}} = json_response(conn, 200)
      assert String.length(generated_rc) == 8
      assert is_binary(generated_rc)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), data: %{"cpf" => "103"})
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "list referrals when user is logged in" do
    setup [:complete_register, :login]

    test "is successful", %{conn: conn} do
      assert %{"data" => %{"token" => token}} = json_response(conn, 200)

      conn =
        conn
        |> recycle()
        |> put_req_header("authorization", "bearer: " <> token)
        |> get(Routes.user_path(conn, :list_user_referrals))

      assert conn.status == 200
    end
  end

  defp complete_register(_context) do
    {:ok, %User{} = user} = Bankr.Accounts.create_or_update_user(@create_attrs)

    [user: user]
  end

  defp login(%{conn: conn, user: user}) do
    conn =
      post(conn, Routes.session_path(conn, :login), %{
        "cpf" => user.cpf,
        "password" => @create_attrs["password"]
      })

    [conn: conn]
  end
end
