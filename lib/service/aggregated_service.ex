defmodule FinTex.Service.AggregatedService do
  @moduledoc false

  alias FinTex.Service.AccountBalance
  alias FinTex.Service.AccountInfo
  alias FinTex.Service.InternalPaymentParameters
  alias FinTex.Service.RecurringPaymentParameters
  alias FinTex.Service.ScheduledPaymentParameters
  alias FinTex.Service.SEPAPaymentParameters
  alias FinTex.Service.ServiceBehaviour
  alias FinTex.Service.TANMedia

  @behaviour ServiceBehaviour
  @services [
    AccountInfo,
    InternalPaymentParameters,
    SEPAPaymentParameters,
    RecurringPaymentParameters,
    ScheduledPaymentParameters,
    AccountBalance,
    TANMedia
  ]


  def has_capability?(_), do: true


  def update_accounts {seq, accounts} do
    @services
    |> Enum.reduce({seq, accounts}, fn(service, acc) ->
      if apply(service, :has_capability?, [{seq, accounts}]) do
        apply(service, :update_accounts, [acc])
      else
        acc
      end
    end)
  end
end
