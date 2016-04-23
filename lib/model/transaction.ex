defmodule FinTex.Model.Transaction do
  @moduledoc """
  The following fields are public:
    * `name`            - Name of originator or recipient
    * `account_number`  - Account number of originator or recipient. This field might be empty if the transaction has no account number, e.g. interest transactions.
    * `bank_code`       - Bank code of originator or recipient. This field might be empty if the transaction has no bank code, e.g. interest transactions.
    * `amount`          - Transaction amount
    * `booking_date`    - Booking date
    * `value_date`      - Value date
    * `purpose`         - Purpose text. This field might be empty if the transaction has no purpose
    * `code`            - Business transaction code
    * `booking_text`    - Booking text. This field might be empty if the transaction has no booking text
    * `booked`          - This flag indicates whether the transaction is booked or pending
  """

  use Timex

  @type t :: %__MODULE__{
    name: binary,
    account_number: binary,
    bank_code: binary,
    amount: %Decimal{},
    booking_date: %DateTime{},
    value_date: %DateTime{},
    purpose: binary,
    code: non_neg_integer,
    booking_text: binary,
    booked: boolean
  }

  defstruct [
    :name,
    :account_number,
    :bank_code,
    :amount,
    :booking_date,
    :value_date,
    :purpose,
    :code,
    :booking_text,
    :booked
  ]

  @doc false
  def from_statement(%MT940.StatementLineBundle{
    account_holder: account_holder,
    account_number: account_number,
    amount: amount,
    bank_code: bank_code,
    code: code,
    details: details,
    entry_date: entry_date,
    funds_code: funds_code,
    transaction_description: transaction_description,
    value_date: value_date
  }) do

    sign = case funds_code do
      :credit         -> +1
      :debit          -> -1
      :return_credit  -> -1
      :return_debit   -> +1
    end

    %__MODULE__{
      name: account_holder |> Enum.join(" "),
      account_number: account_number,
      bank_code: bank_code,
      amount: amount |> Decimal.mult(sign |> Decimal.new),
      booking_date: entry_date,
      value_date: value_date,
      purpose: details |> Enum.join(" "),
      code: code,
      booking_text: transaction_description
    }
  end
end
