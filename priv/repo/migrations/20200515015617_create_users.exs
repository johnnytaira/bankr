defmodule Bankr.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string
      add :cpf, :string
      add :cpf_hash, :string
      add :birth_date, :string
      add :gender, :string
      add :city, :string
      add :state, :string
      add :country, :string
      add :registration_status, :string, default: "pendente"
      add :generated_rc, :string, size: 8
      add :indication_rc, :string, size: 8
      add :password, :string

      timestamps(type: :utc_datetime, default: fragment("timezone('utc', now())"))
    end

    #create unique_index(:users, [:cpf])
  end
end
