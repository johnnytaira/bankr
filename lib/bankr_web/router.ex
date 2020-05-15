defmodule BankrWeb.Router do
  use BankrWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", BankrWeb do
    pipe_through :api
  end
end
