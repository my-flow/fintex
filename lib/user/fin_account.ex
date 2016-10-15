defprotocol FinTex.User.FinAccount do

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


defimpl FinTex.User.FinAccount, for: [FinTex.Model.Account, Map] do

  def account_number(account) do
    account |> Map.get(:account_number)
  end

  def subaccount_id(account) do
    account |> Map.get(:subaccount_id)
  end

  def blz(account) do
    account |> Map.get(:blz)
  end

  def iban(account) do
    account |> Map.get(:iban)
  end

  def bic(account) do
    account |> Map.get(:bic)
  end

  def owner(account) do
    account |> Map.get(:owner)
  end
end


defimpl FinTex.User.FinAccount, for: List do

  def account_number(account) do
    account |> Keyword.get(:account_number)
  end

  def subaccount_id(account) do
    account |> Keyword.get(:subaccount_id)
  end

  def blz(account) do
    account |> Keyword.get(:blz)
  end

  def iban(account) do
    account |> Keyword.get(:iban)
  end

  def bic(account) do
    account |> Keyword.get(:bic)
  end

  def owner(account) do
    account |> Keyword.get(:owner)
  end
end
