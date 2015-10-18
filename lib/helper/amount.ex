defmodule FinTex.Helper.Amount do

  def parse(string, sign) when is_binary(string) and (sign == -1 or sign == 1) do
    string
    |> parse
    |> Decimal.mult(sign |> Decimal.new)
  end


  def parse(string) when is_binary(string) do
    string
    |> String.replace(",", ".")
    |> String.replace(~r/\.$/, ".00")
    |> Decimal.new
  end
end
