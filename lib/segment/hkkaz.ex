defmodule FinTex.Segment.HKKAZ do
  @moduledoc false

  alias FinTex.Model.Account
  alias FinTex.Model.Dialog
  alias FinTex.Helper.Segment

  defstruct [:account, :from, :to, :start_point, segment: nil]

  import Segment
  use Timex

  def new(
    %__MODULE__{
      account: %Account{
        iban:           iban,
        bic:            bic,
        blz:            blz,
        account_number: account_number,
        subaccount_id:  subaccount_id
      },
      from: from,
      to: to,
      start_point: start_point
    },
    d = %Dialog{
      country_code: country_code
    }
  ) do

    v = max_version(d, __MODULE__)

    ktv = if v >= 7 do
      [iban, bic]
    else
      [account_number, subaccount_id, country_code, blz]
    end

    %__MODULE__{
      segment:
        [
        	["HKKAZ", "?", v],
          ktv,
          "N",
          case from do
            nil -> ""
            _   -> from |> Timex.format!("%Y%m%d", :strftime)
          end,
          case to do
            nil -> ""
            _   -> to |> Timex.format!("%Y%m%d", :strftime)
          end,
          "",
          start_point
        ]
    }
  end

end


defimpl Inspect, for: FinTex.Segment.HKKAZ do
  use FinTex.Helper.Inspect
end
