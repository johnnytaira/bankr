defmodule Bankr.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string
      add :cpf, :string
      add :birth_date, :string
      add :gender, :string
      add :city, :string
      add :state, :string
      add :country, :string

      timestamps()
    end
  end
end
