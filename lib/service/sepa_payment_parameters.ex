defmodule FinTex.Service.SEPAPaymentParameters do
  @moduledoc false

  alias FinTex.Model.PaymentType
  alias FinTex.Service.AbstractService
  alias FinTex.User.FinAccount

  use AbstractService


  @max_purpose_length 140


  def has_capability? {_, accounts} do
    accounts
    |> Map.values
    |> Enum.all?(fn %FinAccount{supported_transactions: supported_transactions} ->
      supported_transactions |> Enum.member?("HKCCS")
    end)
  end


  def update_account(seq, account = %FinAccount{}) do
    account = %FinAccount{account |
      supported_payments: %{
        SEPA: %PaymentType{
          allowed_recipients: nil,
          max_purpose_length: @max_purpose_length
        }
      }
    }

    {seq, account}
  end
end
