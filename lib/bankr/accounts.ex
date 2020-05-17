defmodule Bankr.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  import Bankr.Hasher
  alias Bankr.Accounts.User
  alias Bankr.Repo
  alias Ecto.Multi

  # desconsiderar os campos referentes à referral_code porque eles serão inseridos depois na base e sempre seram null
  @referral_code_fields ~w(registration_status generated_rc indication_rc)a
  # desconsiderar os campos inseridos automaticamente porque não é informação que o usuário manda
  @auto_generated_keys ~w(id inserted_at updated_at __meta__ __struct__)a

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

  def find_and_confirm_password(%{"cpf" => plain_cpf, "password" => password}) do
    case get_user_by_cpf(plain_cpf) do
      nil -> {:error, :unauthorized}
      user -> check_password(user, password)
    end
  end

  defp check_password(user, plain_password) do
    case Bcrypt.check_pass(user, plain_password, hash_key: :password) do
      {:ok, user} -> {:ok, user}
      {:error, _reason} -> {:error, :unauthorized}
    end
  end

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
    user_changeset_by_cpf(plain_cpf, attrs)
    |> check_valid_rc(attrs)
    |> register_user()
    |> update_user_status()
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
    cpf_hash = hash_string(plain_cpf)
    Repo.get_by(User, cpf_hash: cpf_hash)
  end

  defp check_valid_rc(changeset, %{"referral_code" => generated_rc} = attrs) do
    valid_indications = from u in User, where: u.generated_rc == ^generated_rc, select: count(u)

    case Repo.all(valid_indications) do
      [0] -> Ecto.Changeset.add_error(changeset, :indication_rc, "invalid")
      _ -> User.indication_changeset(changeset, attrs)
    end
  end

  defp check_valid_rc(changeset, _attrs) do
    changeset
  end

  defp register_user(changeset) do
    Repo.insert_or_update(changeset)
  end

  defp update_user_status({:error, _reason} = response), do: response

  defp update_user_status({:ok, %User{} = user} = response) do
    exclusion_fields = @auto_generated_keys ++ @referral_code_fields

    filled_fields =
      user
      |> Map.drop(exclusion_fields)
      |> Map.values()
      |> Enum.filter(&(is_nil(&1) == false))

    expected_user_keys = user |> Map.drop(exclusion_fields) |> Map.keys()

    case length(filled_fields) == length(expected_user_keys) do
      true ->
        User.complete_registration_changeset(user, %{"registration_status" => "completo"})
        |> Repo.update()

      false ->
        response
    end
  end
end
