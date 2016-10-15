defprotocol FinTex.User.FinBank do

  @doc "8 digits bank code"
  @spec blz(t) :: binary
  def blz(bank)


  @doc "URL of the bank server."
  @spec url(t) :: binary
  def url(bank)


  @doc "API version. Possible values are `220` or `300`."
  @spec version(t) :: binary
  def version(bank)
end


defimpl FinTex.User.FinBank, for: [FinTex.Model.Bank, Map] do

  def blz(bank) do
    bank |> Map.get(:blz)
  end


  def url(bank) do
    bank |> Map.get(:url)
  end


  def version(bank) do
    bank |> Map.get(:version)
  end
end


defimpl FinTex.User.FinBank, for: List do

  def blz(bank) do
    bank |> Keyword.get(:blz)
  end


  def url(bank) do
    bank |> Keyword.get(:url)
  end


  def version(bank) do
    bank |> Keyword.get(:version)
  end
end
