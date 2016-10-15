defmodule FinTex.Validator.CurrencyTest do
  use ExUnit.Case

  test "keyword list, provided currency validation" do
    assert Vex.valid?([component: "EUR"],  component: [currency: true])
    assert Vex.valid?([component: "USD"],  component: [currency: []])
    refute Vex.valid?([component: "äöü"],  component: [currency: true])
    refute Vex.valid?([component: "EURO"], component: [currency: []])
  end
end
