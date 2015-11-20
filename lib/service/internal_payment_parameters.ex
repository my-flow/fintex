defmodule FinTex.Service.InternalPaymentParameters do
  @moduledoc false

  alias FinTex.Command.AbstractCommand
  alias FinTex.Command.Sequencer
  alias FinTex.Model.Account
  alias FinTex.Model.PaymentType
  alias FinTex.Segment.HKCUB
  alias FinTex.Segment.HNHBK
  alias FinTex.Segment.HNHBS
  alias FinTex.Segment.HNSHA
  alias FinTex.Segment.HNSHK
  alias FinTex.Service.AbstractService
  alias FinTex.Service.SEPAPaymentParameters
  alias FinTex.Service.ServiceBehaviour

  use AbstractCommand
  use AbstractService

  @behaviour ServiceBehaviour


  def has_capability?(seq, account = %Account{supported_transactions: supported_transactions}) do
    !SEPAPaymentParameters.has_capability?(seq, account) &&
    supported_transactions |>  Enum.member?("HKCUM") &&
    supported_transactions |>  Enum.member?("HKCUB")
  end


  def update_account(seq, account = %Account{supported_payments: supported_payments}) do
    {seq, recipient_accounts} = seq |> check_recipient_accounts(account, [])

    sepa_payment = supported_payments |> Dict.get(:SEPA, %PaymentType{})

    account = %Account{account |
      supported_payments: %{
        SEPA: %PaymentType{sepa_payment | allowed_recipients: recipient_accounts |> Enum.to_list}
      }
    }

    {seq |> Sequencer.inc, account}
  end



  defp check_recipient_accounts(seq, account, recipient_accounts, start_point \\ nil) do
    request_segments = [
      %HNHBK{},
      %HNSHK{},
      %HKCUB{account: account, start_point: start_point},
      %HNSHA{},
      %HNHBS{}
    ]

    {:ok, response} = seq |> Sequencer.call_http(request_segments)

    recipient_accounts = recipient_accounts
    |> Stream.concat(response[:HICUB] |> Stream.map(fn s -> s |> to_account end))

    start_point = response[:HIRMS]
    |> to_messages
    |> Stream.filter_map(fn [code | _] -> code === 3040 end, fn [_code, _ref, _text, start_point] -> start_point end)
    |> Enum.at(0)

    seq = seq |> Sequencer.inc

    case start_point do
      nil -> {seq, recipient_accounts}
      _   -> check_recipient_accounts(seq, account, recipient_accounts, start_point)
    end
  end


  defp to_account(raw) do
    [iban, bic | _] = raw |> Enum.at(2)
    %Account{iban: iban, bic: bic}
  end
end
