defmodule BankrWeb.Router do
  use BankrWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated do
    plug Guardian.Plug.EnsureAuthenticated
  end

  scope "/api", BankrWeb do
    pipe_through :api
    resources "/registration", UserController, only: [:create, :show]
    post "/login", SessionController, :login
  end

  scope "/api/v1/", BankrWeb do
    pipe_through :authenticated
  end
end
