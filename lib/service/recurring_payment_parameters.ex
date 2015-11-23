defmodule FinTex.Service.RecurringPaymentParameters do
  @moduledoc false

  alias FinTex.Command.Sequencer
  alias FinTex.Model.Account
  alias FinTex.Model.PaymentType
  alias FinTex.Service.AbstractService
  alias FinTex.Service.ServiceBehaviour

  use AbstractService


  @behaviour ServiceBehaviour


  def has_capability?(_, %Account{supported_transactions: supported_transactions}) do
    supported_transactions |>  Enum.member?("HKDAE")
  end


  def update_account(seq, account = %Account{supported_payments: supported_payments}) do
    sepa_payment = supported_payments |> Dict.get(:SEPA, %PaymentType{})

    account = %Account{account |
      supported_payments: %{
        SEPA: %PaymentType{sepa_payment | can_be_recurring: true}
      }
    }

    {seq |> Sequencer.inc, account}
  end
end
