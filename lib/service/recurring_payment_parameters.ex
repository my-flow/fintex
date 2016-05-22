defmodule FinTex.Service.RecurringPaymentParameters do
  @moduledoc false

  alias FinTex.Command.Sequencer
  alias FinTex.Model.PaymentType
  alias FinTex.Service.AbstractService
  alias FinTex.User.FinAccount

  use AbstractService


  def has_capability? {_, accounts} do
    accounts
    |> Map.values
    |> Enum.all?(fn %FinAccount{supported_transactions: supported_transactions} ->
      supported_transactions |>  Enum.member?("HKDAE")
    end)
  end


  def update_account(seq, account = %FinAccount{supported_payments: supported_payments}) do
    sepa_payment = supported_payments |> Map.get(:SEPA, %PaymentType{})

    account = %FinAccount{account |
      supported_payments: %{
        SEPA: %PaymentType{sepa_payment | can_be_recurring: true}
      }
    }

    {seq |> Sequencer.inc, account}
  end
end
