defmodule Bankr.Accounts.User do
  @moduledoc """
  Model do usuário a ser registrado.
  As validações seguem os formatos convencionados em BankrWeb.UserController
  """
  alias Bankr.Accounts.User
  alias Bankr.EncryptedField
  use Ecto.Schema
  import Ecto.Changeset
  import Bankr.Hasher
  import Cpfcnpj, only: [valid?: 1]

  # desconsiderar os campos referentes à referral_code porque eles serão inseridos depois na base e sempre seram null
  @referral_code_fields ~w(registration_status generated_rc indication_rc)a
  # desconsiderar os campos inseridos automaticamente porque não é informação que o usuário manda
  @auto_generated_keys ~w(id inserted_at updated_at __meta__ __struct__)a

  @valid_genders ~w(male female other prefer_not_to_say)

  schema "users" do
    field :birth_date, EncryptedField
    field :cpf, EncryptedField
    field :cpf_hash, :string
    field :email, EncryptedField
    field :name, EncryptedField

    field :city, :string
    field :country, :string
    field :gender, :string
    field :password, :string
    field :state, :string
    field :registration_status, :string, default: "pending"
    field :generated_rc, :string
    field :indication_rc, :string

    timestamps()
  end

  @exclusion_fields [@auto_generated_keys | @referral_code_fields]

  @doc """
  Verifica se todos os campos foram preenchidos (removendo os `@exclusion_fields`)

  Retorna a quantidade de campos preenchidos.

  """
  @spec get_amount_filled_fields(%User{}) :: integer()
  def get_amount_filled_fields(user) do
    user
    |> Map.drop(@exclusion_fields)
    |> Map.values()
    |> Enum.filter(&(is_nil(&1) == false))
    |> length()
  end

  @doc """
  Verifica quais são os campos esperados para preencher (removendo os `@exclusion_fields`)

  Retorna a quantidade de campos esperados.
  """
  @spec get_expected_fields(%User{}) :: integer()
  def get_expected_fields(user) do
    user |> Map.drop(@exclusion_fields) |> Map.keys() |> length()
  end

  @doc """
  Changeset para quando o usuário tiver um código de indicação válido. Somente será chamado se o referral_code estiver explícito no parâmetro da requisição.
  """
  def indication_changeset(user, %{"referral_code" => generated_rc}) do
    user
    |> cast(%{"indication_rc" => generated_rc}, [:indication_rc])
  end

  def indication_changeset(user, _attrs) do
    user
  end

  @doc """
  Changeset para a conclusão do registro. Será chamado quando o usuário conseguir preencher todos os campos. Gera um código de indicação.
  """
  def complete_registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:registration_status])
    |> generate_referral_code()
  end

  @required ~w(cpf)a
  @optional ~w(name email birth_date gender city state country registration_status password)a
  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @optional ++ @required)
    |> deny_user_input_status()
    |> validate_required(@required)
    |> validate_inclusion(:gender, @valid_genders)
    |> unique_constraint(:cpf)
    |> put_cpf()
    |> put_password()
    |> put_birth_date()
    |> validate_format(:email, ~r/(\w+)@(\w+)\.(\w)/)
  end

  defp deny_user_input_status(
         %Ecto.Changeset{valid?: true, changes: %{registration_status: _}} = changeset
       ) do
    validate_change(changeset, :registration_status, fn :registration_status, _ ->
      [registration_status: "you can't do this, bitch"]
    end)
  end

  defp deny_user_input_status(changeset), do: changeset

  defp put_cpf(%Ecto.Changeset{valid?: true, changes: %{cpf: cpf}} = changeset) do
    changeset
    |> validate_change(
      :cpf,
      fn :cpf, cpf ->
        case valid?({:cpf, cpf}) do
          true -> []
          false -> [cpf: "invalid"]
        end
      end
    )
    |> change(%{cpf_hash: hash_string(cpf)})
  end

  defp put_cpf(changeset), do: changeset

  defp put_password(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password: Bcrypt.hash_pwd_salt(password))
  end

  defp put_password(changeset), do: changeset

  defp put_birth_date(
         %Ecto.Changeset{valid?: true, changes: %{birth_date: birth_date}} = changeset
       ) do
    case Date.from_iso8601(birth_date) do
      {:ok, _date} -> changeset
      {:error, _reason} -> add_error(changeset, :birth_date, "invalid_format")
    end
  end

  defp put_birth_date(changeset), do: changeset

  defp generate_referral_code(
         %Ecto.Changeset{valid?: true, changes: %{registration_status: "completed"}} = changeset
       ) do
    change(changeset, generated_rc: Bankr.ReferralGen.random())
  end

  defp generate_referral_code(changeset), do: changeset
end
