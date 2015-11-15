defmodule FinTex.Model.FinBankTest do
  alias FinTex.Model.Bank
  alias FinTex.User.FinBank
  use ExUnit.Case
  use FinTex

  @blz "10000000"
  @url "http://example.org/"
  @version "220"


  test "it should create a new struct" do
    bank = %FinBank{blz: @blz, url: @url, version: @version}
    assert nil != bank
    assert @blz == bank |> Bank.blz
    assert @url == bank |> Bank.url
    assert @version == bank |> Bank.version
  end


  test "it should validate blz" do
    refute %FinBank{blz: "0", url: @url, version: @version} |> Vex.valid?
    refute %FinBank{blz: "123456789", url: @url, version: @version} |> Vex.valid?
    refute %FinBank{blz: "abcdefgh", url: @url, version: @version} |> Vex.valid?
  end


  test "it should validate URL" do
    refute %FinBank{blz: @blz, url: "asdf", version: @version} |> Vex.valid? # protocol missing
    refute %FinBank{blz: @blz, url: "http://google.com/", version: @version} |> Vex.valid? # https protocol missing
    refute %FinBank{blz: @blz, url: "https://asdfasdfasdf/", version: @version} |> Vex.valid? # host not found
  end


  test "it should validate version" do
    refute %FinBank{blz: @blz, url: @url, version: "200"} |> Vex.valid?
  end
end
