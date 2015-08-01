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

  @type t :: %__MODULE__{
    sender_account: FinTex.Model.Account.t,
    receiver_account: FinTex.Model.Account.t,
    amount: %Decimal{},
    currency: binary,
    purpose: binary,
    tan_scheme: FinTex.Model.TANScheme.t
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

  validates :amount, presence: true

  validates :currency, presence: true, format: ~r/^[A-Z]{3}$/

  validates :purpose, presence: true, length: [in: 1..140]

  validates :tan_scheme, presence: true

end
