defmodule FinTex.Service.ScheduledPaymentParameters do
  @moduledoc false

  alias FinTex.Command.Sequencer
  alias FinTex.Model.Account
  alias FinTex.Model.PaymentType
  alias FinTex.Service.AbstractService
  alias FinTex.Service.ServiceBehaviour

  use AbstractService
  use Timex

  @behaviour ServiceBehaviour


  def has_capability?(_, %Account{supported_transactions: supported_transactions}) do
    supported_transactions |> Enum.member?("HKCSE")
  end


  def update_account(seq, account = %Account{supported_payments: supported_payments}) do
    day_limits = (seq |> Sequencer.dialog).bpd
    |> Map.get("HICSES")
    |> Enum.at(0)
    |> Enum.at(4)

    sepa_payment = supported_payments |> Map.get(:SEPA, %PaymentType{})

    account = %Account{account |
      supported_payments: %{
        SEPA: %PaymentType{sepa_payment |
          can_be_scheduled:   true,
          min_scheduled_date: Date.now |> Date.shift(days: day_limits |> Enum.at(0)),
          max_scheduled_date: Date.now |> Date.shift(days: day_limits |> Enum.at(1)),
        }
      }
    }

    {seq, account}
  end
end
