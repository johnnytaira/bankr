defmodule BankrWeb.UserControllerTest do
  use BankrWeb.ConnCase
  import Brcpfcnpj, only: [cpf_generate: 0]

  alias Bankr.Accounts
  alias Bankr.Accounts.User
  @password "password"

  @partial_valid_attrs %{
    "birth_date" => "2010-04-17",
    "cpf" => cpf_generate(),
    "email" => "valid@email.com",
    "password" => @password
  }

  @create_attrs %{
    "birth_date" => "2010-04-17",
    "city" => "São Paulo",
    "country" => "Brasil",
    "cpf" => cpf_generate(),
    "email" => "valid@email.com",
    "gender" => "male",
    "name" => "A Name",
    "state" => "SP",
    "password" => @password
  }

  @valid_indication_attrs %{
    "birth_date" => "2010-04-17",
    "city" => Faker.Address.city(),
    "country" => Faker.Address.country(),
    "cpf" => cpf_generate(),
    "email" => Faker.Internet.free_email(),
    "gender" => "other",
    "name" => Faker.StarWars.En.character(),
    "state" => Faker.Address.city_prefix(),
    "password" => @password
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), data: @create_attrs)
      assert %{"id" => id, "generated_rc" => generated_rc} = json_response(conn, 201)["data"]
      assert String.length(generated_rc) == 8
      assert is_binary(generated_rc)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), data: %{"cpf" => "103"})
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "list referrals when user is logged in" do
    setup [:complete_register, :login, :create_referral]

    test "is successful", %{conn: conn} do
      assert %{"data" => %{"token" => token}} = json_response(conn, 200)

      conn =
        conn
        |> recycle()
        |> put_req_header("authorization", "bearer: " <> token)
        |> get(Routes.user_path(conn, :list_user_referrals))

      assert %{"data" => expected} = json_response(conn, 200)

      assert length(expected) == 1

      Enum.map(expected, fn user ->
        assert not is_nil(Accounts.get_user!(user["id"]))
        assert is_integer(user["id"])
        assert is_binary(user["name"])
      end)
    end
  end

  describe "list referrals when a user has any referrals" do
    setup [:complete_register, :login]

    test "returns a empty list", %{conn: conn} do
      assert %{"data" => %{"token" => token}} = json_response(conn, 200)

      conn =
        conn
        |> recycle()
        |> put_req_header("authorization", "bearer: " <> token)
        |> get(Routes.user_path(conn, :list_user_referrals))

      assert %{"data" => expected} = json_response(conn, 200)

      assert Enum.empty?(expected)
    end
  end

  describe "list referrals when a pending user is logged in" do
    setup [:partial_register, :login]

    test "is forbidden", %{conn: conn} do
      assert %{"data" => %{"token" => token}} = json_response(conn, 200)

      conn =
        conn
        |> recycle()
        |> put_req_header("authorization", "bearer: " <> token)
        |> get(Routes.user_path(conn, :list_user_referrals))

      assert expected = json_response(conn, 403)
    end
  end

  defp complete_register(_context) do
    {:ok, %User{} = user} = Bankr.Accounts.create_or_update_user(@create_attrs)

    [user: user]
  end

  defp partial_register(_context) do
    {:ok, %User{} = user} = Bankr.Accounts.create_or_update_user(@partial_valid_attrs)

    [user: user]
  end

  defp create_referral(%{user: user}) do
    Bankr.Accounts.create_or_update_user(
      @valid_indication_attrs
      |> Map.put("referral_code", user.generated_rc)
    )

    :ok
  end

  defp login(%{conn: conn, user: user}) do
    conn =
      post(conn, Routes.session_path(conn, :login), %{
        "cpf" => user.cpf,
        "password" => @password
      })

    [conn: conn]
  end
end
