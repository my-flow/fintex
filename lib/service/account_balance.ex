defmodule FinTex.Service.AccountBalance do
  @moduledoc false

  alias FinTex.Command.AbstractCommand
  alias FinTex.Command.Sequencer
  alias FinTex.Model.Dialog
  alias FinTex.Model.Balance
  alias FinTex.Segment.HNHBK
  alias FinTex.Segment.HNSHK
  alias FinTex.Segment.HKSAL
  alias FinTex.Segment.HNSHA
  alias FinTex.Segment.HNHBS
  alias FinTex.Service.AbstractService
  alias FinTex.Service.SEPAInfo
  alias FinTex.User.FinAccount

  use AbstractCommand
  use AbstractService
  use Timex


  def has_capability? {seq, accounts} do
    SEPAInfo.has_capability?({seq, accounts})
    && accounts
    |> Map.values
    |> Enum.all?(&do_has_capability?(seq, &1))
  end


  defp do_has_capability?(seq, %FinAccount{supported_transactions: supported_transactions, iban: iban, bic: bic}) do
    %Dialog{bpd: bpd} = seq
    |> Sequencer.dialog

    params = bpd
    |> Map.get("HKSPA" |> control_structure_to_bpd)
    |> Enum.at(0)
    |> Enum.at(4)

    sepa_allowed = params |> Enum.at(1) == "J" || iban != nil && bic != nil

    sepa_allowed && supported_transactions |> Enum.member?("HKSAL")
  end


  def update_account(seq, account = %FinAccount{}) do
    request_segments = [
      %HNHBK{},
      %HNSHK{},
      %HKSAL{account: account},
      %HNSHA{},
      %HNHBS{}
    ]

    {:ok, response} = seq |> Sequencer.call_http(request_segments)

    info = response[:HISAL] |> Enum.at(0)

    account = %FinAccount{account |
      balance: %Balance{
        balance:          info |> Enum.at(4) |> Enum.at(1),
        balance_date:     to_date(
                             info |> Enum.at(4) |> Enum.at(3),
                             info |> Enum.at(4) |> Enum.at(4)
                          ),
        credit_line:      info |> Enum.at(6, []) |> Enum.at(0),
        amount_available: info |> Enum.at(7, []) |> Enum.at(0) ||
                          info |> Enum.at(8, []) |> Enum.at(0)
      }
    }

    {seq |> Sequencer.inc, account}
  end


  defp to_date(date, nil) when is_binary(date) and byte_size(date) == 8 do
    to_date(date, "000000")
  end


  defp to_date(date, time)
  when is_binary(date) and is_binary(time) and byte_size(date) == 8 and byte_size(time) == 6 do
    date = ~r"(\d{4})(\d{2})(\d{2})" |> Regex.run(date, capture: :all_but_first) |> Enum.map(&String.to_integer/1)
    time = ~r"(\d{2})(\d{2})(\d{2})" |> Regex.run(time, capture: :all_but_first) |> Enum.map(&String.to_integer/1)

    Timex.to_datetime(
      {
        {Enum.at(date, 0), Enum.at(date, 1), Enum.at(date, 2)},
        {Enum.at(time, 0), Enum.at(time, 1), Enum.at(time, 2)},
      },
      "GMT"
    )
  end
end
