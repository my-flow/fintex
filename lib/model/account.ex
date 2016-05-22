defprotocol FinTex.Model.Account do

  @doc "Account number"
  @spec account_number(t) :: String.t
  def account_number(account)

  @doc "Subaccount ID"
  @spec subaccount_id(t) :: String.t
  def subaccount_id(account)

  @doc "Bank code"
  @spec blz(t) :: String.t
  def blz(account)

  @doc "IBAN"
  @spec iban(t) :: String.t
  def iban(account)

  @doc "BIC"
  @spec bic(t) :: String.t
  def bic(account)

  @doc "Name of the account holder"
  @spec owner(t) :: String.t
  def owner(account)
end
