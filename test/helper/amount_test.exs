defmodule FinTex.Helper.AmountTest do
  alias FinTex.Helper.Amount
  use ExUnit.Case

  test "convert amount" do
    assert "0" |> Decimal.new == "0" |> Amount.parse
    assert "0.00" |> Decimal.new == "0," |> Amount.parse
    assert "0.01" |> Decimal.new == "0,01" |> Amount.parse
    assert "12345.67" |> Decimal.new == "12345,67" |> Amount.parse
  end


  test "convert amount with sign" do
    assert "-0" |> Decimal.new == "0" |> Amount.parse(-1)
    assert "-0.00" |> Decimal.new == "0," |> Amount.parse(-1)
    assert "-0.01" |> Decimal.new == "0,01" |> Amount.parse(-1)
    assert "-12345.67" |> Decimal.new == "12345,67" |> Amount.parse(-1)
  end
end
