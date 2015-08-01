defmodule FinTex.Model.Balance do

  alias FinTex.Model.Balance

  @moduledoc """
  The following fields are public:
    * `balance`      - Account balance
    * `balance_date` - Bank server timestamp of balance
    * `credit_line`  - Credit line
  """

  use Timex

  @type t :: %__MODULE__{
    balance: Balance.t,
    balance_date: %Timex.DateTime{},
    credit_line: %Decimal{},
  }

  defstruct [
    :balance,
    :balance_date,
    :credit_line,
  ]

end
