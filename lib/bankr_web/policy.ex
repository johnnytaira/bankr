defmodule BankrWeb.Policy do
  @moduledoc """
  Implementa o `Bodyguard.Policy`
  """

  @behaviour Bodyguard.Policy

  @doc """
    Na função `BankrWeb.UserController.list_user_referrals/2`, somente usuários
    com status de registro completo podem visualizar as indicações
  """
  @spec authorize(atom(), %Bankr.Accounts.User{}, any()) :: :ok | {:error, :reason}
  def authorize(:list_user_referrals, %{registration_status: "completed"}, _opts), do: :ok

  def authorize(:list_user_referrals, _user, _opts), do: {:error, :incomplete_registration}

  def authorize(_, _, _), do: :ok
end
