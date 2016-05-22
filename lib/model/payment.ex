defprotocol FinTex.Model.Payment do

  alias FinTex.Model.Account
  alias FinTex.Model.TANScheme

  @doc "Bank account of the sender"
  @spec sender_account(t) :: Account.t
  def sender_account(payment)


  @doc "Bank account of the receiver"
  @spec receiver_account(t) :: Account.t
  def receiver_account(payment)


  @doc "Order amount"
  @spec amount(t) :: %Decimal{}
  def amount(payment)


  @doc "Three-character currency code (ISO 4217)"
  @spec currency(t) :: String.t
  def currency(payment)


  @doc "Purpose text"
  @spec purpose(t) :: String.t
  def purpose(payment)


  @doc "TAN scheme"
  @spec tan_scheme(t) :: TANScheme.t
  def tan_scheme(payment)
end
