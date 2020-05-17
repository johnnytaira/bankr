defmodule Bankr.EncryptedField do
  @moduledoc """
  Baseado no tutorial: https://github.com/dwyl/phoenix-ecto-encryption-example

  Implementa um novo tipo para o Ecto. No caso, EncryptedField é uma string que será armazenada como binary no banco e
  """

  alias Bankr.AES

  @spec type :: :binary
  @behaviour Ecto.Type
  def type, do: :binary

  @spec cast(binary) :: {:ok, String.t()}
  def cast(value) do
    {:ok, to_string(value)}
  end

  @spec dump(binary) :: {:ok, <<_::32, _::_*8>>}
  def dump(value) do
    cipher = value |> to_string() |> AES.encrypt()
    {:ok, cipher}
  end

  @spec load(<<_::64, _::_*8>>) :: {:ok, :error | binary}
  def load(value) do
    {:ok, AES.decrypt(value)}
  end

  def embed_as(_), do: :self

  @spec equal?(binary, binary) :: boolean
  def equal?(value1, value2), do: value1 == value2
end
