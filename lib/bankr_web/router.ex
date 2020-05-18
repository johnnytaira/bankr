defmodule BankrWeb.Router do
  use BankrWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated do
    plug BankrWeb.AuthPipeline
  end

  scope "/api", BankrWeb do
    pipe_through :api
    resources "/register", UserController, only: [:create]
    post "/login", SessionController, :login
  end

  scope "/api/v1/", BankrWeb do
    pipe_through :authenticated
    get "/referrals", UserController, :list_user_referrals
  end
end
