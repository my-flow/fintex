defmodule FinTex.Validator.LatinCharSetTest do
  use ExUnit.Case

  test "keyword list, provided latin char set validation" do
    assert Vex.valid?([component: "x1234?Az"], component: [latin_char_set: true])
    assert Vex.valid?([component: nil],        component: [latin_char_set: []])
    refute Vex.valid?([component: "äöüß"],     component: [latin_char_set: []])
  end
end
