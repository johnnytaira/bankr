defmodule BankrWeb.ErrorHandler do
  @moduledoc false
  import Plug.Conn

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler

  @spec auth_error(Plug.Conn.t(), {any, any}, any) :: Plug.Conn.t()
  def auth_error(conn, {type, _reason}, _opts) do
    body = to_string(type)

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(401, body)
    |> halt()
  end
end
