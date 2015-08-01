defimpl Vex.Blank, for: Decimal do
  def blank?(nil), do: true
  def blank?(_),  do: false
end

defimpl Vex.Blank, for: FinTex.Model.Account do
  def blank?(nil), do: true
  def blank?(_),  do: false
end

defimpl Vex.Blank, for: FinTex.Model.TANScheme do
  def blank?(nil), do: true
  def blank?(_),  do: false
end
