defmodule FinTex.Service.AggregatedService do
  @moduledoc false

  alias FinTex.Service.AccountBalance
  alias FinTex.Service.AccountInfo
  alias FinTex.Service.InternalPaymentParameters
  alias FinTex.Service.RecurringPaymentParameters
  alias FinTex.Service.ScheduledPaymentParameters
  alias FinTex.Service.SEPAPaymentParameters
  alias FinTex.Service.ServiceBehaviour

  @behaviour ServiceBehaviour
  @services [
    AccountInfo,
    InternalPaymentParameters,
    SEPAPaymentParameters,
    RecurringPaymentParameters,
    ScheduledPaymentParameters,
    AccountBalance
  ]


  def has_capability?(_, _), do: true


  def update_accounts {seq, accounts} do
    @services
    |> Enum.reduce({seq, accounts}, fn(service, acc) -> service.update_accounts(acc) end)
  end
end
