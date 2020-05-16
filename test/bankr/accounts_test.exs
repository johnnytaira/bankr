defmodule Bankr.AccountsTest do
  use Bankr.DataCase
  import Brcpfcnpj, only: [cpf_generate: 0]
  import Bcrypt

  alias Bankr.Accounts

  describe "users" do
    alias Bankr.Accounts.User

    @valid_attrs %{
      birth_date: ~D[2010-04-17],
      city: "São Paulo",
      country: "Brasil",
      cpf: cpf_generate(),
      email: "valid@email.com",
      gender: "male",
      name: "A Name",
      referral_code: "some referral_code",
      state: "SP"
    }
    @update_attrs %{
      birth_date: ~D[2011-05-18],
      city: "Los Angeles",
      country: "Estados Unidos",
      cpf: cpf_generate(),
      email: "valid2@email.com",
      gender: "female",
      name: "Another Name",
      referral_code: "some updated referral_code",
      state: "California"
    }

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_or_update_user()

      user
    end

    test "create_or_update_user/1 with valid data creates a user" do
      assert {:ok, %User{} = expected} = Accounts.create_or_update_user(@valid_attrs)

      assert expected.birth_date ==
               check_pass(expected, @valid_attrs.birth_date, hash_key: :birth_date)

      assert expected.city == @valid_attrs.city
      assert expected.country == @valid_attrs.country
      assert expected.cpf == check_pass(expected, @valid_attrs.cpf, hash_key: :cpf)
      assert expected.email == check_pass(expected, @valid_attrs.email, hash_key: :email)
      assert expected.gender == @valid_attrs.gender
      assert expected.name == check_pass(expected, @valid_attrs.name, hash_key: :name)
      assert expected.referral_code == @valid_attrs.referral_code
      assert expected.state == @valid_attrs.state
    end

    test "create_or_update_user/1 with invalid email returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_or_update_user(%{"cpf" => cpf_generate()})
    end

    test "create_or_update_user/1 with invalid cpf returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_or_update_user(%{"cpf" => "123"})
    end

    test "create_or_update_user/1 with invalid gender returns error changeset" do
      assert {:error,
              %Ecto.Changeset{} =
                Accounts.create_or_update_user(%{"cpf" => cpf_generate(), "gender" => "invalid"})}
    end

    test "create_or_update_user/1 with valid data completes the registration when cpf is already registered" do
      cpf = cpf_generate()
      email = "some@email.com"
      assert {:ok, _} = Accounts.create_or_update_user(%{"cpf" => cpf})

      assert {:ok, %User{} = expected} =
               Accounts.create_or_update_user(%{"cpf" => cpf, "email" => email})

      assert expected.email == email
    end

    @tag :skip
    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end
  end
end
