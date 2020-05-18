defmodule Bankr.Guardian do
  @moduledoc """
    Utiliza a implementação do `Guardian`.
  """
  use Guardian, otp_app: :bankr
  alias Bankr.Accounts.User
  alias Bankr.Repo

  def subject_for_token(%User{} = user, _claims), do: {:ok, to_string(user.id)}
  def subject_for_token(_, _), do: {:error, "Unknown resource type"}

  def resource_from_claims(%{"sub" => id}), do: {:ok, Repo.get(User, id)}
  def resource_from_claims(_), do: {:error, :resource_not_found}
end
