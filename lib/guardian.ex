defmodule Bankr.Guardian do
  @moduledoc """
    Utiliza a implementação do `Guardian`.
  """
  use Guardian, otp_app: :bankr

  def subject_for_token(resource, _claims) do
    IO.inspect "passa no subject_for_token"
    IO.inspect resource
    sub = to_string(resource.id)
    {:ok, sub}
  end

  def subject_for_token(_, _) do
    {:error, :reason_for_error}
  end

  def resource_from_claims(claims) do
    IO.inspect "passa no resource_from_claims"

    id = claims["sub"]
    resource = Bankr.Accounts.get_user!(id)
    {:ok, resource}
  end

  def resource_from_claims(_claims) do
    {:error, :reason_for_error}
  end
end
