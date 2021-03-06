defmodule Bankr.AccountsTest do
  use Bankr.DataCase
  import Brcpfcnpj, only: [cpf_generate: 0]
  alias Bankr.Accounts

  alias Bankr.Accounts.User

  @partial_valid_attrs %{
    "birth_date" => "2010-04-17",
    "cpf" => cpf_generate(),
    "email" => "valid@email.com"
  }

  @valid_attrs %{
    "birth_date" => "2010-04-17",
    "city" => Faker.Address.city(),
    "country" => Faker.Address.country(),
    "cpf" => cpf_generate(),
    "email" => Faker.Internet.free_email(),
    "gender" => "male",
    "name" => Faker.StarWars.En.character(),
    "state" => Faker.Address.city_prefix(),
    "password" => "password"
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
    "password" => "password"
  }

  @valid_second_indication_attrs %{
    "birth_date" => "2000-04-17",
    "city" => Faker.Address.city(),
    "country" => Faker.Address.country(),
    "cpf" => cpf_generate(),
    "email" => Faker.Internet.free_email(),
    "gender" => "female",
    "name" => Faker.StarWars.En.character(),
    "state" => Faker.Address.city_prefix(),
    "password" => "password"
  }

  @valid_third_indication_attrs %{
    "birth_date" => "2000-04-17",
    "city" => Faker.Address.city(),
    "country" => Faker.Address.country(),
    "cpf" => cpf_generate(),
    "email" => Faker.Internet.free_email(),
    "gender" => "prefer_not_to_say",
    "name" => Faker.StarWars.En.character(),
    "state" => Faker.Address.city_prefix(),
    "password" => "password"
  }

  describe "create_or_update_users" do
    test "create_or_update_user/1 with valid data creates a user with status 'completed" do
      assert {:ok, %User{} = expected} = Accounts.create_or_update_user(@valid_attrs)

      assert expected.birth_date == @valid_attrs["birth_date"]
      assert expected.cpf == @valid_attrs["cpf"]
      assert expected.email == @valid_attrs["email"]
      assert expected.name == @valid_attrs["name"]
      assert expected.city == @valid_attrs["city"]
      assert expected.country == @valid_attrs["country"]
      assert expected.gender == @valid_attrs["gender"]
      assert expected.state == @valid_attrs["state"]
      assert expected.registration_status == "completed"
      assert is_binary(expected.generated_rc)
      assert String.length(expected.generated_rc) == 8
    end

    test "create_or_update_user/1 with valid data and a referral code returns a user with status completed and a record in indication_rc" do
      assert {:ok, %User{generated_rc: generated_rc}} =
               Accounts.create_or_update_user(@valid_attrs)

      assert {:ok, %User{indication_rc: indication_rc} = expected} =
               Accounts.create_or_update_user(
                 @valid_indication_attrs
                 |> Map.put("referral_code", generated_rc)
               )

      assert String.length(indication_rc) == 8
      assert generated_rc == indication_rc
    end

    test "create_or_update_user/1 completed in two parts returns a user with status completed and a referral_code" do
      assert {:ok, %User{cpf: cpf}} = Accounts.create_or_update_user(@partial_valid_attrs)

      new_attrs = %{
        "city" => "São Paulo",
        "country" => "Brasil",
        "gender" => "male",
        "name" => "A Name",
        "state" => "SP",
        "password" => "password",
        "cpf" => cpf
      }

      assert {:ok, %User{registration_status: "completed"} = expected} =
               Accounts.create_or_update_user(new_attrs)

      assert is_binary(expected.generated_rc)
    end

    test "create_or_update_user/1 with valid data and a invalid referral code returns an error" do
      assert {:ok, %User{}} = Accounts.create_or_update_user(@valid_attrs)

      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_or_update_user(
                 @valid_indication_attrs
                 |> Map.put("referral_code", "invalid1")
               )
    end

    test "create_or_update_user/1 with valid and incomplete data creates a user with status 'pending'" do
      assert {:ok, %User{} = expected} = Accounts.create_or_update_user(@partial_valid_attrs)

      assert expected.email == @partial_valid_attrs["email"]
      assert expected.cpf == @partial_valid_attrs["cpf"]
      assert expected.birth_date == @partial_valid_attrs["birth_date"]
      assert expected.registration_status == "pending"
    end

    test "create_or_update_user/1 with invalid birth date returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_or_update_user(%{
                 "cpf" => cpf_generate(),
                 "birth_date" => "012/32/13495"
               })
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

      assert expected.email == email
      assert Bankr.Repo.get_by(User, cpf_hash: Bankr.Hasher.hash_string(cpf)) == expected
      assert expected.registration_status == "pending"
    end

    test "create_or_update_user/1 with registration_status in params returns error" do
      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_or_update_user(%{
                 "cpf" => cpf_generate(),
                 "registration_status" => "completed"
               })
    end
  end

  describe "list referrals" do
    setup [:create_user, :create_referrals]

    test "user with three referrals returns success", %{user: user} do
      expected = Accounts.list_user_referrals(user)
      assert is_list(expected)
      assert length(expected) == 3

      Enum.map(expected, fn user ->
        assert not is_nil(Accounts.get_user!(user.id))
        assert is_integer(user.id)
        assert is_binary(user.name)
      end)
    end
  end

  defp create_user(_context) do
    {:ok, user} = Accounts.create_or_update_user(@valid_attrs)

    [user: user]
  end

  defp create_referrals(%{user: %{generated_rc: generated_rc}}) do
    {:ok, %User{}} =
      Accounts.create_or_update_user(
        @valid_indication_attrs
        |> Map.put("referral_code", generated_rc)
      )

    {:ok, %User{}} =
      Accounts.create_or_update_user(
        @valid_second_indication_attrs
        |> Map.put("referral_code", generated_rc)
      )

    {:ok, %User{}} =
      Accounts.create_or_update_user(
        @valid_third_indication_attrs
        |> Map.put("referral_code", generated_rc)
      )

    :ok
  end
end
