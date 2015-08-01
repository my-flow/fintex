defmodule FinTex.Model.Account do

  alias FinTex.Model.Balance
  alias FinTex.Model.TANScheme

  @moduledoc """
  The following fields are public:
    * `account_number`          - Account number
    * `subaccount_id`           - Subaccount ID
    * `blz`                     - Bank code
    * `bank_name`               - Bank name
    * `currency`                - Three-character currency code (ISO 4217)
    * `iban`                    - IBAN
    * `bic`                     - BIC
    * `name`                    - Account name
    * `owner`                   - Account owner
    * `balance`                 - Account balance
    * `supported_payments`      - List of payment types with payment parameters
    * `supported_tan_schemes`   - List of TAN schemes
    * `preferred_tan_scheme`    - Security function of the TAN scheme preferred by the user
    * `supported_transactions`  - List of supported transactions
  """

  @type t :: %__MODULE__{
    account_number: binary,
    subaccount_id: binary,
    blz: binary,
    bank_name: binary,
    currency: binary,
    iban: binary,
    bic: binary,
    name: binary,
    owner: binary,
    balance: Balance.t,
#    supported_payments: [],
    supported_tan_schemes: [TANScheme.t],
    preferred_tan_scheme: binary,
    supported_transactions: [binary]
  }

  defstruct [
    :account_number,
    :subaccount_id,
    :blz,
    :bank_name,
    :currency,
    :iban,
    :bic,
    :name,
    :owner,
    balance: nil,
#    supported_payments: [],
    supported_tan_schemes: [],
    preferred_tan_scheme: nil,
    supported_transactions: []
  ]

end
