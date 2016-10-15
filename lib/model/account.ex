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
    * `owner`                   - Name of the account holder
    * `type`                    - Account type. Possible values are `:giro_account`, `:savings_account`,
                                  `:credit_card` or `:loan_account`, `:cash_book`, `:depot` or `:unknown`.
    * `balance`                 - Account balance
    * `supported_payments`      - List of payment types with payment parameters
    * `supported_transactions`  - List of transaction names
    * `supported_tan_schemes`   - List of TAN schemes
    * `preferred_tan_scheme`    - Security function of the TAN scheme preferred by the user
  """

  alias FinTex.Model.Balance
  alias FinTex.Model.TANScheme
  alias FinTex.User.FinAccount

  @type t :: %__MODULE__{
    type: Atom.t,
    account_number: String.t,
    subaccount_id: String.t,
    blz: String.t,
    bank_name: String.t,
    currency: String.t,
    iban: String.t,
    bic: String.t,
    name: String.t,
    owner: String.t,
    balance: Balance.t,
    supported_payments: map,
    supported_tan_schemes: [TANScheme.t],
    preferred_tan_scheme: String.t,
    supported_transactions: [String.t]
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
    supported_payments: Map.new,
    supported_tan_schemes: [],
    preferred_tan_scheme: nil,
    supported_transactions: []
  ]

  use Vex.Struct

  validates :blz, blz: [allow_nil: true]

  validates :iban, presence: [if: :bic], iban: [if: :bic]

  validates :bic, presence: [if: :iban], bic: [if: :iban]

  validates :owner, presence: true, length: [in: 1..140]

  @doc false
  @spec from_account(FinAccount.t) :: t
  def from_account(account) do
    %__MODULE__{
      account_number:         account |> FinAccount.account_number,
      subaccount_id:          account |> FinAccount.subaccount_id,
      blz:                    account |> FinAccount.blz,
      iban:                   account |> FinAccount.iban,
      bic:                    account |> FinAccount.bic,
      owner:                  account |> FinAccount.owner
    }
  end


  def key(%__MODULE__{
    account_number: account_number,
    subaccount_id: subaccount_id
  }) do
    "#{account_number}#{subaccount_id}"
  end
end
