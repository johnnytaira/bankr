defmodule BankrWeb.UserView do
  use BankrWeb, :view
  alias BankrWeb.UserView

  def render("referrals.json", %{users: users}) do
    %{data: render_many(users, UserView, "referral.json")}
  end

  def render("referral.json", %{user: user}) do
    %{
      id: user.id,
      name: user.name
    }
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json"), message: "Cadastrado com sucesso!"}
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      name: user.name,
      email: user.email,
      cpf: user.cpf,
      birth_date: user.birth_date,
      gender: user.gender,
      city: user.city,
      state: user.state,
      country: user.country,
      registration_status: user.registration_status,
      generated_rc: user.generated_rc
    }
  end
end
