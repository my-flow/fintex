defmodule FinTex.Model.Payment do
  @moduledoc """
  The following fields are public:
    * `sender_account`    - Bank account of the sender
    * `receiver_account`  - Bank account of the receiver
    * `amount`            - Order amount
    * `currency`          - Three-character currency code (ISO 4217)
    * `purpose`           - Purpose text
    * `tan_scheme`        - TAN scheme
  """

  alias FinTex.Model.Account
  alias FinTex.Model.TANScheme

  @type t :: %__MODULE__{
    sender_account: Account.t,
    receiver_account: Account.t,
    amount: %Decimal{},
    currency: String.t,
    purpose: String.t,
    tan_scheme: TANScheme.t
  }

  defstruct [
    :sender_account,
    :receiver_account,
    :amount,
    :currency,
    :purpose,
    :tan_scheme
  ]

  use Vex.Struct

  validates :sender_account, presence: true

  validates :receiver_account, presence: true

  validates :amount, amount: true

  validates :currency, presence: true, currency: true

  validates :purpose, presence: true, latin_char_set: true, length: [in: 1..140]

  validates :tan_scheme, presence: true

end
