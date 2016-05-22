defmodule FinTex.Model.FinBankTest do
  alias FinTex.DataProvider
  alias FinTex.Model.Bank
  alias FinTex.User.FinBank
  use ExUnit.Case
  use FinTex


  test "it should accept a struct" do
    bank = DataProvider.bank |> FinBank.from_bank

    assert nil != bank
    assert bank.blz == bank |> Bank.blz
    assert bank.url == bank |> Bank.url
    assert bank.version == bank |> Bank.version
  end


  test "it should accept a map" do
    bank = DataProvider.bank

    assert nil != bank
    assert bank.blz == bank |> Bank.blz
    assert bank.url == bank |> Bank.url
    assert bank.version == bank |> Bank.version
  end


  test "it should accept a keyword" do
    bank = DataProvider.bank |> Enum.to_list
    assert nil != bank
    assert bank[:blz] == bank |> Bank.blz
    assert bank[:url] == bank |> Bank.url
    assert bank[:version] == bank |> Bank.version
  end


  test "it should validate blz" do
    bank = DataProvider.bank |> FinBank.from_bank

    assert %FinBank{bank | blz: "10000000"} |> Vex.valid?
    assert %FinBank{bank | blz: "12030000"} |> Vex.valid?
    assert %FinBank{bank | blz: "10100100"} |> Vex.valid?

    refute %FinBank{bank | blz: "0"} |> Vex.valid?
    refute %FinBank{bank | blz: "123456789"} |> Vex.valid?
    refute %FinBank{bank | blz: "abcdefgh"} |> Vex.valid?
  end


  test "it should validate URL" do
    bank = DataProvider.bank |> FinBank.from_bank

    refute %FinBank{bank | url: "asdf"} |> Vex.valid? # protocol missing
    refute %FinBank{bank | url: "http://google.com/"} |> Vex.valid? # https protocol missing
    refute %FinBank{bank | url: "https://asdfasdfasdf/"} |> Vex.valid? # host not found
  end


  test "it should validate version" do
    bank = DataProvider.bank |> FinBank.from_bank

    refute %FinBank{bank | version: "200"} |> Vex.valid?
  end
end
