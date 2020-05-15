defmodule Bankr.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :birth_date, :date
    field :city, :string
    field :country, :string
    field :cpf, :string
    field :email, :string
    field :gender, :string
    field :name, :string
    field :referral_code, :string
    field :state, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :cpf, :birth_date, :gender, :city, :state, :country, :referral_code])
    |> validate_required([:name, :email, :cpf, :birth_date, :gender, :city, :state, :country, :referral_code])
  end
end
