defimpl Vex.Blank, for: Decimal do
  def blank?(nil), do: true
  def blank?(_),  do: false
end

defimpl Vex.Blank, for: FinTex.User.FinAccount do
  def blank?(nil), do: true
  def blank?(_),  do: false
end

defimpl Vex.Blank, for: FinTex.User.FinTANScheme do
  def blank?(nil), do: true
  def blank?(_),  do: false
end

defimpl Vex.Blank, for: Date do
  def blank?(nil), do: true
  def blank?(_),  do: false
end
