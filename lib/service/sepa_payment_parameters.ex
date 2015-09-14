defmodule FinTex.Service.SEPAPaymentParameters do
  @moduledoc false

  alias FinTex.Model.Account
  alias FinTex.Model.PaymentType
  alias FinTex.Service.AbstractService
  alias FinTex.Service.ServiceBehaviour

  use AbstractService


  @behaviour ServiceBehaviour
  @max_purpose_length 140


  def has_capability? %Account{supported_transactions: supported_transactions} do
    supported_transactions |> Enum.member?("HKCCS")
  end


  def update_account(seq, account = %Account{}) do
    account = %Account{account |
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
