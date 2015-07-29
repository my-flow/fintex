defmodule FinTex.Segment.HKSAL do
  @moduledoc false

  alias FinTex.Model.Account
  alias FinTex.Model.Dialog
  alias FinTex.Segment.Segment

  defstruct [:account]

  import Segment

  def create(
    %__MODULE__{
      account: %Account{
        :iban           => iban,
        :bic            => bic,
        :blz            => blz,
        :account_number => account_number,
        :subaccount_id  => subaccount_id
      }
    },
    d = %Dialog{
      :country_code => country_code
    }
  ) do

    v = max_version(d, __MODULE__)
    ktv = case v do
      6 when iban != nil and bic != nil -> [iban, bic]
      7 when iban != nil and bic != nil -> [iban, bic]
      _                                   -> [account_number, subaccount_id, country_code, blz]
    end

    [
      ["HKSAL", "?", v],
      ktv,
      "N"
    ]
  end
end
