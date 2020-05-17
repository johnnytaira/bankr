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
    "state" => "SP"
  }

  # @update_attrs %{
  #   "data":{
  #     "birth_date": "2010-04-17",
  #     "city": "São Paulo",
  #     "country": "Brasil",
  #     "cpf": "32432018028",
  #     "email": "valid@email.com",
  #     "gender": "male",
  #     "name": "A Name",
  #     "state": "SP"
  #   }
  # }
  # @invalid_attrs %{
  #   birth_date: nil,
  #   city: nil,
  #   country: nil,
  #   cpf: nil,
  #   email: nil,
  #   gender: nil,
  #   name: nil,
  #   referral_code: nil,
  #   state: nil
  # }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), data: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), data: %{"cpf" => "103"})
      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end
