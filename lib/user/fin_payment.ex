defmodule FinTex.User.FinPayment do
  @moduledoc """
  The following fields are public:
    * `sender_account`    - Bank account of the sender
    * `receiver_account`  - Bank account of the receiver
    * `amount`            - Order amount
    * `currency`          - Three-character currency code (ISO 4217)
    * `purpose`           - Purpose text
    * `tan_scheme`        - TAN scheme
  """

  alias FinTex.Model.Payment
  alias FinTex.User.FinAccount
  alias FinTex.User.FinTANScheme

  import XmlBuilder
  use Timex

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

  validates :sender_account, presence: true, by: &FinAccount.valid?(&1)

  validates :receiver_account, presence: true, by: &FinAccount.valid?(&1)

  validates :amount, amount: true

  validates :currency, presence: true, currency: true

  validates :purpose, presence: true, latin_char_set: true, length: [in: 1..140]

  validates :tan_scheme, presence: true


  @doc false
  @spec from_payment(Payment.t) :: t
  def from_payment(payment) do
    %__MODULE__{
      sender_account:   payment |> Payment.sender_account |> FinAccount.from_account,
      receiver_account: payment |> Payment.receiver_account |> FinAccount.from_account,
      amount:           payment |> Payment.amount,
      currency:         payment |> Payment.currency,
      purpose:          payment |> Payment.purpose,
      tan_scheme:       payment |> Payment.tan_scheme |> FinTANScheme.from_tan_scheme
    }
  end


  def to_sepa_pain_message(%__MODULE__{} = payment, schema) when is_binary(schema) do
    %__MODULE__{
      sender_account: %FinAccount{
        iban:  sender_iban,
        bic:   sender_bic,
        owner: sender_owner
      },
      receiver_account: %FinAccount{
        iban:  receiver_iban,
        bic:   receiver_bic,
        owner: receiver_owner
      },
      amount: amount,
      currency: currency,
      purpose: purpose
    } = payment

    amount = sanitize(amount)
    purpose = sanitize(purpose)

    sender_iban = sanitize(sender_iban)
    sender_bic = sanitize(sender_bic)
    sender_owner = sanitize(sender_owner)

    receiver_iban = sanitize(receiver_iban)
    receiver_bic = sanitize(receiver_bic)
    receiver_owner = sanitize(receiver_owner)

    :Document
    |> doc(
      %{
        "xmlns":              schema,
        "xsi:schemaLocation": schema |> schema_to_location,
        "xmlns:xsi":          "http://www.w3.org/2001/XMLSchema-instance"
      },
      [
        CstmrCdtTrfInitn: [
          GrpHdr: [
            MsgId: "M" <> Timex.format!(DateTime.now, "%Y%m%d%H%M%S", :strftime),
            CreDtTm: Timex.format!(DateTime.now, "{ISOz}"),
            NbOfTxs: 1,
            CtrlSum: amount,
            InitgPty: [
              Nm: sender_owner
            ]
          ],
          PmtInf: [
            PmtInfId: "P" <> Timex.format!(DateTime.now, "%Y%m%d%H%M%S", :strftime),
            PmtMtd: "TRF",
            NbOfTxs: 1,
            CtrlSum: amount,
            PmtTpInf: [
              SvcLvl: [
                Cd: "SEPA"
              ]
            ],
            ReqdExctnDt: "1999-01-01",
            Dbtr: [
              Nm: sender_owner
            ],
            DbtrAcct: [
              Id: [
                IBAN: sender_iban
              ],
              Ccy: currency
            ],
            DbtrAgt: [
              FinInstnId: [
                BIC: sender_bic
              ]
            ],
            ChrgBr: "SLEV",
            CdtTrfTxInf: [
              PmtId: [
                EndToEndId: "NOTPROVIDED"
              ],
              Amt: [
                {:InstdAmt, %{Ccy: currency}, amount}
              ],
              CdtrAgt: [
                FinInstnId: [
                  BIC: receiver_bic
                ]
              ],
              Cdtr: [
                Nm: receiver_owner
              ],
              CdtrAcct: [
                Id: [
                  IBAN: receiver_iban
                ]
              ],
              RmtInf: [
                Ustrd: purpose
              ]
            ]
          ]
        ]
      ]
    )
    |> String.replace("\n", "")
    |> String.replace("\t", "")
  end


  defp schema_to_location(schema) when is_binary(schema) do
    ~r/^(.*:)(pain.*)$/
    |> Regex.replace(schema, "\\1\\2 \\2.xsd", global: false)
  end


  defp sanitize(input) do
    input
    |> to_string
  end
end


defimpl FinTex.Model.Payment, for: [FinTex.User.FinPayment, Map] do

  def sender_account(account) do
    account |> Map.get(:sender_account)
  end

  def receiver_account(account) do
    account |> Map.get(:receiver_account)
  end

  def amount(account) do
    account |> Map.get(:amount)
  end

  def currency(account) do
    account |> Map.get(:currency)
  end

  def purpose(account) do
    account |> Map.get(:purpose)
  end

  def tan_scheme(account) do
    account |> Map.get(:tan_scheme)
  end
end


defimpl FinTex.Model.Payment, for: List do

  def sender_account(account) do
    account |> Keyword.get(:sender_account)
  end

  def receiver_account(account) do
    account |> Keyword.get(:receiver_account)
  end

  def amount(account) do
    account |> Keyword.get(:amount)
  end

  def currency(account) do
    account |> Keyword.get(:currency)
  end

  def purpose(account) do
    account |> Keyword.get(:purpose)
  end

  def tan_scheme(account) do
    account |> Keyword.get(:tan_scheme)
  end
end
