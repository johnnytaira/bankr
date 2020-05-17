defmodule Bankr.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Bankr.Repo

  alias Bankr.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Cria um usuário, caso o CPF não esteja cadastrado. Se o CPF não estiver cadastrado, atualiza.


  ## Examples

      iex> create_or_update_user(%{"cpf" => Cpfcnpj.generate()})
      {:ok, %User{}}

      iex> create_or_update_user(%{"cpf" => "001203"})
      {:error, %Ecto.Changeset{}}

  """
  def create_or_update_user(%{"cpf" => plain_cpf} = attrs) do
    case get_user_by_cpf(plain_cpf) do
      nil -> %User{}
      user -> user
    end
    |> User.changeset(attrs)
    |> Repo.insert_or_update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @spec get_user_by_cpf(String.t()) :: struct | nil
  defp get_user_by_cpf(plain_cpf) do
    hash_cpf = Bcrypt.hash_pwd_salt(plain_cpf)
    Repo.get_by(User, cpf: hash_cpf)
  end
end
