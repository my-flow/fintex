defmodule FinTex.Model.BankTest do
  alias FinTex.DataProvider
  alias FinTex.Model.Bank
  alias FinTex.User.FinBank
  use ExUnit.Case
  use FinTex


  test "it should accept a struct" do
    bank = DataProvider.bank |> Bank.from_bank

    assert nil != bank
    assert bank.blz == bank |> FinBank.blz
    assert bank.url == bank |> FinBank.url
    assert bank.version == bank |> FinBank.version
  end


  test "it should accept a map" do
    bank = DataProvider.bank

    assert nil != bank
    assert bank.blz == bank |> FinBank.blz
    assert bank.url == bank |> FinBank.url
    assert bank.version == bank |> FinBank.version
  end


  test "it should accept a keyword" do
    bank = DataProvider.bank |> Enum.to_list
    assert nil != bank
    assert bank[:blz] == bank |> FinBank.blz
    assert bank[:url] == bank |> FinBank.url
    assert bank[:version] == bank |> FinBank.version
  end


  test "it should validate blz" do
    bank = DataProvider.bank |> Bank.from_bank

    assert %Bank{bank | blz: "10000000"} |> Vex.valid?
    assert %Bank{bank | blz: "12030000"} |> Vex.valid?
    assert %Bank{bank | blz: "10100100"} |> Vex.valid?

    refute %Bank{bank | blz: "0"} |> Vex.valid?
    refute %Bank{bank | blz: "123456789"} |> Vex.valid?
    refute %Bank{bank | blz: "abcdefgh"} |> Vex.valid?
  end


  test "it should validate URL" do
    bank = DataProvider.bank |> Bank.from_bank

    refute %Bank{bank | url: "asdf"} |> Vex.valid? # protocol missing
    refute %Bank{bank | url: "http://google.com/"} |> Vex.valid? # https protocol missing
    refute %Bank{bank | url: "https://asdfasdfasdf/"} |> Vex.valid? # host not found
  end


  test "it should validate version" do
    bank = DataProvider.bank |> Bank.from_bank

    refute %Bank{bank | version: "200"} |> Vex.valid?
  end
end
