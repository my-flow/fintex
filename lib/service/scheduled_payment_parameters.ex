defmodule FinTex.Service.ScheduledPaymentParameters do
  @moduledoc false

  alias FinTex.Controller.Sequencer
  alias FinTex.Model.Account
  alias FinTex.Model.PaymentType
  alias FinTex.Service.AbstractService

  use AbstractService
  use Timex


  def has_capability? {_, accounts} do
    accounts
    |> Map.values
    |> Enum.all?(fn %Account{supported_transactions: supported_transactions} ->
      supported_transactions |> Enum.member?("HKCSE")
    end)
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
          min_scheduled_date: Timex.today |> Timex.shift(days: day_limits |> Enum.at(0)),
          max_scheduled_date: Timex.today |> Timex.shift(days: day_limits |> Enum.at(1)),
        }
      }
    }

    {seq, account}
  end
end
