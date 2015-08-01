defprotocol FinTex.Model.Bank do

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
