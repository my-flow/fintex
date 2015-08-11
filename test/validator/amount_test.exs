defmodule FinTex.Validator.AmountTest do
  use ExUnit.Case

  test "keyword list, provided amount validation" do
    assert Vex.valid?([component: Decimal.new("0.01")], component: [amount: true])
    refute Vex.valid?([component: Decimal.new("0.00")], component: [amount: true])

    assert Vex.valid?([component: Decimal.new("999999999.99")], component: [amount: true])
    refute Vex.valid?([component: Decimal.new("9999999999.99")], component: [amount: true])

    assert Vex.valid?([component: Decimal.new("1")], component: [amount: true])
    assert Vex.valid?([component: Decimal.new("1.2")], component: [amount: true])
    assert Vex.valid?([component: Decimal.new("1.23")], component: [amount: true])
    assert Vex.valid?([component: "1.23"], component: [amount: true])
    assert Vex.valid?([component: 1.23], component: [amount: true])
    assert Vex.valid?([component: 1], component: [amount: true])

    refute Vex.valid?([component: -2], component: [amount: true])

    Decimal.set_context(%Decimal.Context{flags: [:rounded, :inexact], precision: 9, rounding: :half_up, traps: []})

    d = Decimal.new("1") |> Decimal.div(Decimal.new("0"))
    refute Vex.valid?([component: d], component: [amount: true])

    d = Decimal.new("0") |> Decimal.div(Decimal.new("0"))
    refute Vex.valid?([component: d], component: [amount: true])
  end
end
