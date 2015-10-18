defmodule FinTex.Service.SEPAInfo do
  @moduledoc false

  alias FinTex.Command.Sequencer
  alias FinTex.Model.Account
  alias FinTex.Segment.HNHBK
  alias FinTex.Segment.HNSHK
  alias FinTex.Segment.HKSPA
  alias FinTex.Segment.HNSHA
  alias FinTex.Segment.HNHBS
  alias FinTex.Service.ServiceBehaviour

  @behaviour ServiceBehaviour


  def has_capability? %Account{supported_transactions: supported_transactions} do
    supported_transactions |> Enum.member?("HKSPA")
  end


  def update_accounts {seq, accounts} do
    request_segments = [
      %HNHBK{},
      %HNSHK{},
      %HKSPA{},
      %HNSHA{},
      %HNHBS{}
    ]

    {:ok, response} = seq |> Sequencer.call_http(request_segments)

    accounts = response[:HISPA]
    |> Enum.at(0, [])
    |> Stream.drop(1)
    |> Stream.filter(fn info -> Enum.at(info, 0) === "J" end)
    |> Enum.map(fn info ->
        account = accounts |> Enum.find(fn %Account{account_number: account_number} -> account_number === Enum.at(info, 3) end)
        %Account{account |
          iban: Enum.at(info, 1),
          bic:  Enum.at(info, 2)
        }
       end)

    {seq |> Sequencer.inc, accounts}
  end
end
