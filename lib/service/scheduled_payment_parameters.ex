defmodule FinTex.Service.ScheduledPaymentParameters do
  @moduledoc false

  alias FinTex.Command.Sequencer
  alias FinTex.Model.PaymentType
  alias FinTex.Service.AbstractService
  alias FinTex.User.FinAccount

  use AbstractService
  use Timex


  def has_capability? {_, accounts} do
    accounts
    |> Map.values
    |> Enum.all?(fn %FinAccount{supported_transactions: supported_transactions} ->
      supported_transactions |> Enum.member?("HKCSE")
    end)
  end


  def update_account(seq, account = %FinAccount{supported_payments: supported_payments}) do
    day_limits = (seq |> Sequencer.dialog).bpd
    |> Map.get("HICSES")
    |> Enum.at(0)
    |> Enum.at(4)

    sepa_payment = supported_payments |> Map.get(:SEPA, %PaymentType{})

    account = %FinAccount{account |
      supported_payments: %{
        SEPA: %PaymentType{sepa_payment |
          can_be_scheduled:   true,
          min_scheduled_date: Date.now |> Timex.shift(days: day_limits |> Enum.at(0)),
          max_scheduled_date: Date.now |> Timex.shift(days: day_limits |> Enum.at(1)),
        }
      }
    }

    {seq, account}
  end
end
