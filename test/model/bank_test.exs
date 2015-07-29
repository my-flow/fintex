defmodule FinTex.Model.BankTest do
  alias FinTex.Model.Bank
  use ExUnit.Case

  @blz "10000000"
  @url "https://google.com/"
  @version "220"


  test "it should create a new struct" do
    bank = Bank.new(@blz, @url, @version)
    assert bank != nil
    assert bank.blz == @blz
    assert bank.url == @url
    assert bank.version == @version
  end


  test "it should validate blz" do
    assert {:error, _} = Bank.new("0", @url, @version)
    assert {:error, _} = Bank.new("123456789", @url, @version)
    assert {:error, _} = Bank.new("abcdefgh", @url, @version)
  end


  test "it should validate URL" do
    assert {:error, _} = Bank.new(@blz, "asdf", @version) # protocol missing
    assert {:error, _} = Bank.new(@blz, "http://google.com/", @version) # https protocol missing
    assert {:error, _} = Bank.new(@blz, "https://asdfasdfasdf/", @version) # host not found
  end


  test "it should validate version" do
    assert {:error, _} = Bank.new(@blz, @url, "200")
  end
end
