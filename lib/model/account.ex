defmodule FinTex.Model.Account do
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
    * `type`                    - Account type. Possible values are `:giro_account`, `:savings_account`,
                                  `:credit_card` or `:loan_account`, `:cash_book`, `:depot` or `:unknown`.
    * `balance`                 - Account balance
    * `supported_payments`      - List of payment types with payment parameters
    * `supported_tan_schemes`   - List of TAN schemes
    * `preferred_tan_scheme`    - Security function of the TAN scheme preferred by the user
  """

  alias FinTex.Model.Balance
  alias FinTex.Model.TANScheme

  @type t :: %__MODULE__{
    type: binary,
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
    supported_payments: Dict.t,
    supported_tan_schemes: [TANScheme.t],
    preferred_tan_scheme: binary,
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
    type: :unknown,
    balance: nil,
    supported_payments: HashDict.new,
    supported_tan_schemes: [],
    preferred_tan_scheme: nil,
    supported_transactions: []
  ]

  def key(%__MODULE__{
    account_number: account_number,
    subaccount_id: subaccount_id
  }) do
    "#{account_number}#{subaccount_id}"
  end
end
