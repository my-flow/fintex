defmodule FinTex.Service.RecurringPaymentParameters do
  @moduledoc false

  alias FinTex.Controller.Sequencer
  alias FinTex.Model.Account
  alias FinTex.Model.PaymentType
  alias FinTex.Service.AbstractService

  use AbstractService


  def has_capability? {_, accounts} do
    accounts
    |> Map.values
    |> Enum.all?(fn %Account{supported_transactions: supported_transactions} ->
      supported_transactions |>  Enum.member?("HKDAE")
    end)
  end


  def update_account(seq, account = %Account{supported_payments: supported_payments}) do
    sepa_payment = supported_payments |> Map.get(:SEPA, %PaymentType{})

    account = %Account{account |
      supported_payments: %{
        SEPA: %PaymentType{sepa_payment | can_be_recurring: true}
      }
    }

    {seq |> Sequencer.inc, account}
  end
end
