defmodule FinTex.Segment.HKKAZ do
  @moduledoc false

  alias FinTex.Model.Account
  alias FinTex.Model.Dialog
  alias FinTex.Segment.Segment

  defstruct [:account, :start_point]

  import Segment

  def create(
    %__MODULE__{
      account: %Account{
        :iban           => iban,
        :bic            => bic,
        :blz            => blz,
        :account_number => account_number,
        :subaccount_id  => subaccount_id
      },
      start_point: start_point
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
    	["HKKAZ", "?", v],
      ktv,
      "N",
      "", # TODO from
      "", # TODO to
      "", # TODO max results
      start_point
    ]
  end

end
