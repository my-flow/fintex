defmodule FinTex.User.FinSEPACreditTransfer do
  @moduledoc """
  The following fields are public:
    * `sender_account`    - Bank account of the sender
    * `recipient_account` - Bank account of the recipient
    * `amount`            - Order amount
    * `currency`          - Three-character currency code (ISO 4217)
    * `purpose`           - Purpose text
    * `tan_scheme`        - TAN scheme
  """

  alias FinTex.Model.SEPACreditTransfer
  alias FinTex.User.FinAccount
  alias FinTex.User.FinTANScheme

  import XmlBuilder
  use Timex

  @type t :: %__MODULE__{
    sender_account: Account.t,
    recipient_account: Account.t,
    amount: %Decimal{},
    currency: String.t,
    purpose: String.t,
    tan_scheme: TANScheme.t
  }

  defstruct [
    :sender_account,
    :recipient_account,
    :amount,
    :currency,
    :purpose,
    :tan_scheme
  ]

  use Vex.Struct

  validates :sender_account, presence: true, by: &FinAccount.valid?(&1)

  validates :recipient_account, presence: true, by: &FinAccount.valid?(&1)

  validates :amount, amount: true

  validates :currency, presence: true, currency: true

  validates :purpose, presence: true, latin_char_set: true, length: [in: 1..140]

  validates :tan_scheme, presence: true


  @doc false
  @spec from_sepa_credit_transfer(SEPACreditTransfer.t) :: t
  def from_sepa_credit_transfer(sepa_credit_transfer) do
    %__MODULE__{
      sender_account:    sepa_credit_transfer |> SEPACreditTransfer.sender_account |> FinAccount.from_account,
      recipient_account: sepa_credit_transfer |> SEPACreditTransfer.recipient_account |> FinAccount.from_account,
      amount:            sepa_credit_transfer |> SEPACreditTransfer.amount,
      currency:          sepa_credit_transfer |> SEPACreditTransfer.currency,
      purpose:           sepa_credit_transfer |> SEPACreditTransfer.purpose,
      tan_scheme:        sepa_credit_transfer |> SEPACreditTransfer.tan_scheme |> FinTANScheme.from_tan_scheme
    }
  end


  def to_sepa_pain_message(%__MODULE__{} = sepa_credit_transfer, schema) when is_binary(schema) do
    %__MODULE__{
      sender_account: %FinAccount{
        iban:  sender_iban,
        bic:   sender_bic,
        owner: sender_owner
      },
      recipient_account: %FinAccount{
        iban:  recipient_iban,
        bic:   recipient_bic,
        owner: recipient_owner
      },
      amount: amount,
      currency: currency,
      purpose: purpose
    } = sepa_credit_transfer

    amount = sanitize(amount)
    purpose = sanitize(purpose)

    sender_iban = sanitize(sender_iban)
    sender_bic = sanitize(sender_bic)
    sender_owner = sanitize(sender_owner)

    recipient_iban = sanitize(recipient_iban)
    recipient_bic = sanitize(recipient_bic)
    recipient_owner = sanitize(recipient_owner)

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
            MsgId: "M" <> Timex.format!(Timex.now, "%Y%m%d%H%M%S", :strftime),
            CreDtTm: Timex.format!(Timex.now, "{ISO:Extended:Z}"),
            NbOfTxs: 1,
            CtrlSum: amount,
            InitgPty: [
              Nm: sender_owner
            ]
          ],
          PmtInf: [
            PmtInfId: "P" <> Timex.format!(Timex.now, "%Y%m%d%H%M%S", :strftime),
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
                  BIC: recipient_bic
                ]
              ],
              Cdtr: [
                Nm: recipient_owner
              ],
              CdtrAcct: [
                Id: [
                  IBAN: recipient_iban
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


defimpl FinTex.Model.SEPACreditTransfer, for: [FinTex.User.FinSEPACreditTransfer, Map] do

  def sender_account(sepa_credit_transfer) do
    sepa_credit_transfer |> Map.get(:sender_account)
  end

  def recipient_account(sepa_credit_transfer) do
    sepa_credit_transfer |> Map.get(:recipient_account)
  end

  def amount(sepa_credit_transfer) do
    sepa_credit_transfer |> Map.get(:amount)
  end

  def currency(sepa_credit_transfer) do
    sepa_credit_transfer |> Map.get(:currency)
  end

  def purpose(sepa_credit_transfer) do
    sepa_credit_transfer |> Map.get(:purpose)
  end

  def tan_scheme(sepa_credit_transfer) do
    sepa_credit_transfer |> Map.get(:tan_scheme)
  end
end


defimpl FinTex.Model.SEPACreditTransfer, for: List do

  def sender_account(sepa_credit_transfer) do
    sepa_credit_transfer |> Keyword.get(:sender_account)
  end

  def recipient_account(sepa_credit_transfer) do
    sepa_credit_transfer |> Keyword.get(:recipient_account)
  end

  def amount(sepa_credit_transfer) do
    sepa_credit_transfer |> Keyword.get(:amount)
  end

  def currency(sepa_credit_transfer) do
    sepa_credit_transfer |> Keyword.get(:currency)
  end

  def purpose(sepa_credit_transfer) do
    sepa_credit_transfer |> Keyword.get(:purpose)
  end

  def tan_scheme(sepa_credit_transfer) do
    sepa_credit_transfer |> Keyword.get(:tan_scheme)
  end
end
