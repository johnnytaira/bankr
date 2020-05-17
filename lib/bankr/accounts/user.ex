defmodule Bankr.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Cpfcnpj, only: [valid?: 1]
  alias Bankr.Accounts.User

  @auto_generated_keys ~w(id registration_status referral_code __meta__ __struct__ inserted_at updated_at)a
  @valid_genders ~w(male female other prefer_not_to_say)

  schema "users" do
    field :birth_date, :string
    field :city, :string
    field :country, :string
    field :cpf, :string
    field :email, :string
    field :gender, :string
    field :name, :string
    field :state, :string
    field :registration_status, :string, default: "pendente"
    field :referral_code, :string

    timestamps()
  end

  @doc false

  @required ~w(cpf)a
  @optional ~w(name email birth_date gender city state country registration_status)a
  def changeset(user, attrs) do
    user
    |> cast(attrs, @optional ++ @required)
    |> deny_user_input_status()
    |> validate_required(@required)
    |> validate_inclusion(:gender, @valid_genders)
    |> put_cpf()
    |> put_birth_date()
    |> put_name()
    |> put_email()
    |> put_status()
    |> generate_referral_code()
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
    |> change(cpf: Bcrypt.hash_pwd_salt(cpf))
  end

  defp put_cpf(changeset), do: changeset

  defp put_birth_date(
         %Ecto.Changeset{valid?: true, changes: %{birth_date: birth_date}} = changeset
       ) do
    change(changeset, birth_date: Bcrypt.hash_pwd_salt(birth_date))
  end

  defp put_birth_date(changeset), do: changeset

  defp put_email(%Ecto.Changeset{valid?: true, changes: %{email: email}} = changeset) do
    changeset
    |> validate_format(:email, ~r/(\w+)@(\w+)\.(\w)/)
    |> change(email: Bcrypt.hash_pwd_salt(email))
  end

  defp put_email(changeset), do: changeset

  defp put_name(%Ecto.Changeset{valid?: true, changes: %{name: name}} = changeset) do
    change(changeset, name: Bcrypt.hash_pwd_salt(name))
  end

  defp put_name(changeset), do: changeset

  defp put_status(%{changes: changes, valid?: true} = changeset) do
    filled_fields =
      changes
      |> Map.values()
      |> Enum.filter(&(is_nil(&1) == false))

    cond do
      length(filled_fields) == length(expected_user_keys()) ->
        change(changeset, registration_status: "completo")

      true ->
        changeset
    end
  end

  defp put_status(changeset), do: changeset

  defp expected_user_keys() do
    Map.keys(%User{})
    |> Enum.filter(&(Enum.member?(@auto_generated_keys, &1) == false))
  end

  defp generate_referral_code(
         %Ecto.Changeset{valid?: true, changes: %{registration_status: "completo"}} = changeset
       ) do
    change(changeset, referral_code: Bankr.ReferralGen.random())
  end

  defp generate_referral_code(changeset), do: changeset
end
