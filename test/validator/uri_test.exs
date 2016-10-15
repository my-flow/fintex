defmodule FinTex.Validator.UriTest do
  use ExUnit.Case

  test "keyword list, provided URI validation" do
    assert Vex.valid?([component: "https://example.org"], component: [uri: true])
    assert Vex.valid?([component: "https://example.org"], component: [uri: []])
    refute Vex.valid?([component: "http://example.org"],  component: [uri: true])
    refute Vex.valid?([component: "http://example"],      component: [uri: []])
    refute Vex.valid?([component: nil],                   component: [uri: []])
  end
end
