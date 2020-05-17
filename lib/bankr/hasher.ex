defmodule Bankr.Hasher do
  @moduledoc """
  Helper que realiza o hash de uma string, utilizando algoritmo da biblioteca Erlang `:crypto`

  """

  @spec hash_string(String.t()) :: String.t()
  def hash_string(string) do
    :crypto.hash(:sha256, string) |> Base.encode64()
  end
end
