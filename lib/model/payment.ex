defmodule FinTex.Model.Payment do

  @moduledoc """
  The following fields are public:
    * `sender_account`      - Bank account of the sender
    * `receiver_account`    - Bank account of the receiver
    * `amount`              - Order amount
    * `currency`            - Three-character currency code (ISO 4217)
    * `purpose`             - Purpose text
    * `tan_scheme`          - TAN scheme
  """

  defstruct [
    :sender_account,
    :receiver_account,
    :amount,
    :currency,
    :purpose,
    :tan_scheme
  ]

  @type t :: %__MODULE__{}

end
