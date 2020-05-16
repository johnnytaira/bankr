defmodule Bankr.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :birth_date, :string
    field :city, :string
    field :country, :string
    field :cpf, :string
    field :email, :string
    field :gender, :string
    field :name, :string
    field :state, :string

    timestamps()
  end

  @doc false

  @required ~w(cpf)a
  @optional ~w(name email birth_date gender city state country)a
  def changeset(user, attrs) do
    user
    |> cast(attrs, @optional ++ @required)
    |> validate_required(@required)
  end
end
