defmodule FinTex.Model.Balance do
  @moduledoc """
  The following fields are public:
    * `balance`           - Account balance
    * `balance_date`      - Bank server timestamp of balance
    * `credit_line`       - Credit line
    * `amount_available`  - Amount available for withdrawal
  """

  @type t :: %__MODULE__{
    balance: %Decimal{},
    balance_date: DateTime.t,
    credit_line: %Decimal{},
    amount_available: %Decimal{}
  }

  defstruct [
    :balance,
    :balance_date,
    :credit_line,
    :amount_available
  ]

end
