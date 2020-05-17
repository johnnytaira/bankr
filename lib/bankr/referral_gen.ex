defmodule Bankr.ReferralGen do
  @moduledoc """
  Gera uma referral_code, usando a biblioteca `EntropyString`.
  A string conterá 8 caracteres.

  """

  use EntropyString, total: 10.0e6, risk: 1.0e12, bits: 36
end
