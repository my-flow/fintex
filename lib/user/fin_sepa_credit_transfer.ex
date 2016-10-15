defprotocol FinTex.User.FinSEPACreditTransfer do

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


defimpl FinTex.User.FinSEPACreditTransfer, for: [FinTex.Model.SEPACreditTransfer, Map] do

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


defimpl FinTex.User.FinSEPACreditTransfer, for: List do

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
