defmodule BankrWeb.UserControllerTest do
  use BankrWeb.ConnCase

  alias Bankr.Accounts
  alias Bankr.Accounts.User

  @create_attrs %{
    birth_date: ~D[2010-04-17],
    city: "some city",
    country: "some country",
    cpf: "some cpf",
    email: "some email",
    gender: "some gender",
    name: "some name",
    referral_code: "some referral_code",
    state: "some state"
  }
  @update_attrs %{
    birth_date: ~D[2011-05-18],
    city: "some updated city",
    country: "some updated country",
    cpf: "some updated cpf",
    email: "some updated email",
    gender: "some updated gender",
    name: "some updated name",
    referral_code: "some updated referral_code",
    state: "some updated state"
  }
  @invalid_attrs %{
    birth_date: nil,
    city: nil,
    country: nil,
    cpf: nil,
    email: nil,
    gender: nil,
    name: nil,
    referral_code: nil,
    state: nil
  }

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert %{
               "id" => id,
               "birth_date" => "2010-04-17",
               "city" => "some city",
               "country" => "some country",
               "cpf" => "some cpf",
               "email" => "some email",
               "gender" => "some gender",
               "name" => "some name",
               "referral_code" => "some referral_code",
               "state" => "some state"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end
