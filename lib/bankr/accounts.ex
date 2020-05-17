defmodule Bankr.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Bankr.Accounts.User
  alias Bankr.Repo
  alias Ecto.Multi

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

  A validação dos campos (CPF, data de nascimento, gênero e email) é feita no Bankr.Accounts.User.changeset/2

  Se o código de indicação que o usuário manda não for válido, o mesmo não será salvo.

  Após a criação do usuário, se todos os campos estiverem preenchidos, é feito o processo de geração do código de indicação

  O retorno será o resultado do Multi mais recente.
  ## Examples

      iex> create_or_update_user(%{"cpf" => Cpfcnpj.generate()})
      {:ok, %User{}}

      iex> create_or_update_user(%{"cpf" => "001203"})
      {:error, %Ecto.Changeset{}}

  """
  def create_or_update_user(%{"cpf" => plain_cpf} = attrs) do
    changeset =
      user_changeset_by_cpf(plain_cpf, attrs)
      |> check_valid_rc(attrs)

    Multi.new()
    |> register_user(changeset)
    |> insert_indication(changeset, attrs)
    |> Repo.transaction()
    |> return_latest_record()
  end

  defp user_changeset_by_cpf(plain_cpf, attrs) do
    case get_user_by_cpf(plain_cpf) do
      nil -> %User{}
      user -> user
    end
    |> User.changeset(attrs)
  end

  @spec get_user_by_cpf(String.t()) :: struct | nil
  defp get_user_by_cpf(plain_cpf) do
    hash_cpf = Bcrypt.hash_pwd_salt(plain_cpf)
    Repo.get_by(User, cpf: hash_cpf)
  end

  defp check_valid_rc(changeset, %{"referral_code" => generated_rc}) do
    valid_indications = from u in User, where: u.generated_rc == ^generated_rc, select: count(u)

    case Repo.all(valid_indications) do
      [0] -> Ecto.Changeset.add_error(changeset, :indication_rc, "invalid")
      _ -> changeset
    end
  end

  defp check_valid_rc(changeset, _attrs) do
    changeset
  end

  defp insert_indication(multi, user, attrs) do
    Multi.insert(multi, :insert_indication, User.indication_changeset(user, attrs))
  end

  defp register_user(multi, changeset) do
    Multi.insert_or_update(multi, :insert_or_update_registration, changeset)
  end

  defp return_latest_record({:ok, %{insert_indication: after_indication}}) do
    {:ok, after_indication}
  end

  defp return_latest_record({:ok, %{insert_or_update_registration: without_indication}}) do
    {:ok, without_indication}
  end

  defp return_latest_record({:error, _multi_name, reason, _}) do
    {:error, reason}
  end
end
