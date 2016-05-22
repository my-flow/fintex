defprotocol FinTex.Model.TANScheme do

  @doc "encoded security function"
  @spec sec_func(t) :: String.t
  def sec_func(credentials)


  @doc "TAN medium name"
  @spec medium_name(t) :: binary | nil
  def medium_name(credentials)
end
