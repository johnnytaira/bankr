defmodule Bankr.Accounts.User do
  @moduledoc """
  Model do usuário a ser registrado.
  As validações seguem os formatos convencionados em BankrWeb.UserController
  """
  use Ecto.Schema
  import Ecto.Changeset
  import Bankr.Hasher
  import Cpfcnpj, only: [valid?: 1]

  @valid_genders ~w(male female other prefer_not_to_say)

  schema "users" do
    field :birth_date, :string
    field :cpf, :string
    field :cpf_hash, :string
    field :email, :string
    field :name, :string

    field :city, :string
    field :country, :string
    field :gender, :string
    field :password, :string
    field :state, :string
    field :registration_status, :string, default: "pendente"
    field :generated_rc, :string
    field :indication_rc, :string

    timestamps()
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
         %Ecto.Changeset{valid?: true, changes: %{registration_status: "completo"}} = changeset
       ) do
    change(changeset, generated_rc: Bankr.ReferralGen.random())
  end

  defp generate_referral_code(changeset), do: changeset
end
