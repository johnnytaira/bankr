defmodule Bankr.AccountsTest do
  use Bankr.DataCase
  import Brcpfcnpj, only: [cpf_generate: 0]
  import Bcrypt

  alias Bankr.Accounts

  describe "users" do
    alias Bankr.Accounts.User

    @valid_attrs %{
      "birth_date" => "2010-04-17",
      "city" => "São Paulo",
      "country" => "Brasil",
      "cpf" => cpf_generate(),
      "email" => "valid@email.com",
      "gender" => "male",
      "name" => "A Name",
      "state" => "SP",
      "referral_code" => "12345678"
    }

    @partial_valid_attrs %{
      "birth_date" => "2010-04-17",
      "cpf" => cpf_generate(),
      "email" => "valid@email.com"
    }

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_or_update_user()

      user
    end

    test "create_or_update_user/1 with valid data creates a user with status 'completo" do
      assert {:ok, %User{} = expected} = Accounts.create_or_update_user(@valid_attrs)

      assert verify_pass(@valid_attrs["birth_date"], expected.birth_date)
      assert verify_pass(@valid_attrs["cpf"], expected.cpf)
      assert verify_pass(@valid_attrs["email"], expected.email)
      assert verify_pass(@valid_attrs["name"], expected.name)

      assert expected.city == @valid_attrs["city"]
      assert expected.country == @valid_attrs["country"]
      assert expected.gender == @valid_attrs["gender"]
      assert expected.state == @valid_attrs["state"]
      assert expected.registration_status == "completo"
      assert is_binary(expected.referral_code)
    end

    test "create_or_update_user/1 with valid and incomplete data creates a user with status 'pendente'" do
      assert {:ok, %User{} = expected} = Accounts.create_or_update_user(@partial_valid_attrs)

      assert verify_pass(@partial_valid_attrs["email"], expected.email)
      assert verify_pass(@partial_valid_attrs["cpf"], expected.cpf)
      assert verify_pass(@partial_valid_attrs["birth_date"], expected.birth_date)
      assert expected.registration_status == "pendente"
    end

    test "create_or_update_user/1 with invalid email returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_or_update_user(%{
                 "cpf" => cpf_generate(),
                 "email" => "invalid123@etc."
               })
    end

    test "create_or_update_user/1 with invalid cpf returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_or_update_user(%{"cpf" => "123"})
    end

    test "create_or_update_user/1 with invalid gender returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_or_update_user(%{"cpf" => cpf_generate(), "gender" => "invalid"})
    end

    test "create_or_update_user/1 with valid data completes the registration when cpf is already registered" do
      cpf = cpf_generate()
      email = "some@email.com"
      assert {:ok, _} = Accounts.create_or_update_user(%{"cpf" => cpf})

      assert {:ok, %User{} = expected} =
               Accounts.create_or_update_user(%{"cpf" => cpf, "email" => email})

      assert verify_pass(email, expected.email)
      assert expected.registration_status == "pendente"
    end

    test "create_or_update_user/1 with registration_status in params returns error" do
      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_or_update_user(%{
                 "cpf" => cpf_generate(),
                 "registration_status" => "completo"
               })
    end
  end
end
