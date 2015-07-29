defmodule FinTex.Model.Balance do

  @moduledoc """
  The following fields are public:
    * `balance`      - Account balance
    * `balance_date` - Bank server timestamp of balance
    * `credit_line`  - Credit line
  """

  defstruct [
    :balance,
    :balance_date,
    :credit_line,
  ]

  @type t :: %__MODULE__{}

end
