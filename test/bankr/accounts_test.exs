defmodule Bankr.AccountsTest do
  use Bankr.DataCase

  alias Bankr.Accounts

  describe "users" do
    alias Bankr.Accounts.User

    @valid_attrs %{birth_date: ~D[2010-04-17], city: "some city", country: "some country", cpf: "some cpf", email: "some email", gender: "some gender", name: "some name", referral_code: "some referral_code", state: "some state"}
    @update_attrs %{birth_date: ~D[2011-05-18], city: "some updated city", country: "some updated country", cpf: "some updated cpf", email: "some updated email", gender: "some updated gender", name: "some updated name", referral_code: "some updated referral_code", state: "some updated state"}
    @invalid_attrs %{birth_date: nil, city: nil, country: nil, cpf: nil, email: nil, gender: nil, name: nil, referral_code: nil, state: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.birth_date == ~D[2010-04-17]
      assert user.city == "some city"
      assert user.country == "some country"
      assert user.cpf == "some cpf"
      assert user.email == "some email"
      assert user.gender == "some gender"
      assert user.name == "some name"
      assert user.referral_code == "some referral_code"
      assert user.state == "some state"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.birth_date == ~D[2011-05-18]
      assert user.city == "some updated city"
      assert user.country == "some updated country"
      assert user.cpf == "some updated cpf"
      assert user.email == "some updated email"
      assert user.gender == "some updated gender"
      assert user.name == "some updated name"
      assert user.referral_code == "some updated referral_code"
      assert user.state == "some updated state"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
