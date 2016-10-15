defprotocol FinTex.User.FinTANScheme do

  @doc "encoded security function"
  @spec sec_func(t) :: String.t
  def sec_func(credentials)


  @doc "TAN medium name"
  @spec medium_name(t) :: String.t | nil
  def medium_name(credentials)
end


defimpl FinTex.User.FinTANScheme, for: [FinTex.Model.TANScheme, Map] do

  def sec_func(tan_scheme) do
    tan_scheme |> Map.get(:sec_func)
  end


  def medium_name(tan_scheme) do
    tan_scheme |> Map.get(:medium_name)
  end
end


defimpl FinTex.User.FinTANScheme, for: List do

  def sec_func(tan_scheme) do
    tan_scheme |> Keyword.get(:sec_func)
  end


  def medium_name(tan_scheme) do
    tan_scheme |> Keyword.get(:medium_name)
  end
end
