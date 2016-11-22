defmodule FinTex.Service.AggregatedService do
  @moduledoc false

  alias FinTex.Service.AbstractService
  alias FinTex.Service.AccountBalance
  alias FinTex.Service.InternalPaymentParameters
  alias FinTex.Service.RecurringPaymentParameters
  alias FinTex.Service.ScheduledPaymentParameters
  alias FinTex.Service.SEPAPaymentParameters
  alias FinTex.Service.TANMedia

  use AbstractService

  @services [
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
      apply(service, :check_capabilities_and_update_accounts, [acc])
    end)
  end
end
