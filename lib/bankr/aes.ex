defmodule Bankr.AES do
  @aad "AES256GCM" # Use AES 256 Bit Keys for Encryption.

  @spec encrypt(String.t()) :: binary
  def encrypt(plaintext) do
    iv = :crypto.strong_rand_bytes(16)
    # get latest key
    key = get_key()
    # get latest ID;
    key_id = get_key_id()
    # {ciphertext, tag} = :crypto.block_encrypt(:aes_gcm, key, iv, {@aad, plaintext, 16})
    {ciphertext, tag} = :crypto.block_encrypt(:aes_gcm, key, iv, {@aad, to_string(plaintext), 16})
    iv <> tag <> <<key_id::unsigned-big-integer-32>> <> ciphertext
  end


  defp get_key do
    get_key_id() |> get_key
  end

  defp get_key(key_id) do
    encryption_keys() |> Enum.at(key_id)
  end

  defp get_key_id do
    Enum.count(encryption_keys()) - 1
  end

  defp encryption_keys do
    Application.get_env(:bankr, Bankr.AES)[:keys]
  end

  def decrypt(ciphertext) do
    <<iv::binary-16, tag::binary-16, key_id::unsigned-big-integer-32, ciphertext::binary>> =
      ciphertext

    :crypto.block_decrypt(:aes_gcm, get_key(key_id), iv, {@aad, ciphertext, tag})
  end


end
