defmodule FinTex.Segment.HKKIF do
  @moduledoc false

  alias FinTex.Helper.Segment
  alias FinTex.Model.Dialog
  alias FinTex.User.FinAccount

  defstruct [:account, :start_point, segment: nil]

  import Segment


  def new(
    %__MODULE__{
      account: %FinAccount{
        iban:           iban,
        bic:            bic,
        blz:            blz,
        account_number: account_number,
        subaccount_id:  subaccount_id
      },
      start_point: start_point
    },
    d = %Dialog{
      country_code: country_code
    }
  ) do

    v = max_version(d, __MODULE__)
    ktv = if iban != nil and bic != nil do
      [iban, bic]
    else
      [account_number, subaccount_id, country_code, blz]
    end

    %__MODULE__{
      segment:
        [
        	["HKKIF", "?", v],
          ktv,
          "N",
          "",
          start_point
        ]
    }
  end

end


defimpl Inspect, for: FinTex.Segment.HKKIF do
  use FinTex.Helper.Inspect
end
