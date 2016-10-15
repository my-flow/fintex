defprotocol FinTex.Model.SEPACreditTransfer do

  alias FinTex.Model.Account
  alias FinTex.Model.TANScheme

  @doc "Bank account of the sender"
  @spec sender_account(t) :: Account.t
  def sender_account(sepa_credit_transfer)


  @doc "Bank account of the recipient"
  @spec recipient_account(t) :: Account.t
  def recipient_account(sepa_credit_transfer)


  @doc "Order amount"
  @spec amount(t) :: %Decimal{}
  def amount(sepa_credit_transfer)


  @doc "Three-character currency code (ISO 4217)"
  @spec currency(t) :: String.t
  def currency(sepa_credit_transfer)


  @doc "Purpose text"
  @spec purpose(t) :: String.t
  def purpose(sepa_credit_transfer)


  @doc "TAN scheme"
  @spec tan_scheme(t) :: TANScheme.t
  def tan_scheme(sepa_credit_transfer)
end
