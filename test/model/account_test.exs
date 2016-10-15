defmodule FinTex.Model.AccountTest do
  alias FinTex.DataProvider
  alias FinTex.Model.Account
  use ExUnit.Case
  use FinTex


  setup do
    {
      :ok,
      fintex: DataProvider.fintex,
      credentials: DataProvider.credentials,
      account: DataProvider.account,
      ibans: DataProvider.ibans,
      bics: DataProvider.bics
    }
  end


  test "it should create a new struct", context do
    assert context[:account]
  end


  test "it should accept a valid account", context do
    assert context[:account]
    |> Account.from_account
    |> Vex.valid?
  end


  test "it should validate IBAN", context do
    fintex = context[:fintex]
    credentials = context[:credentials]
    account = context[:account]

    for iban <- [nil, "", "123"] do
      account = account |> Map.put(:iban, iban)

      {:error, _} = FinTex.transactions(fintex, credentials, account, nil, nil, [])
      refute account
      |> Account.from_account
      |> Vex.valid?
    end
  end


  test "it should validate BIC", context do
    fintex = context[:fintex]
    credentials = context[:credentials]
    account = context[:account]

    for bic <- [nil, "", "123"] do
      account = account |> Map.put(:bic, bic)

      {:error, _} = FinTex.transactions(fintex, credentials, account, nil, nil, [])
      refute account
      |> Account.from_account
      |> Vex.valid?
    end
  end


  test "it should validate BLZ", context do
    fintex = context[:fintex]
    credentials = context[:credentials]
    account = context[:account]

    for blz <- ["", "1234567"] do
      account = account |> Map.put(:blz, blz)

      {:error, _} = FinTex.transactions(fintex, credentials, account, nil, nil, [])
      refute account
      |> Account.from_account
      |> Vex.valid?
    end
  end


  test "it should validate IBAN and BIC", context do
    account = context[:account]
    |> Map.put(:iban, nil)
    |> Map.put(:bic, nil)
    |> Account.from_account

    assert account |> Vex.valid?

    zip = context[:ibans] |> Stream.zip(context[:bics])

    for {iban, bic} <- zip do
      assert account
      |> Map.put(:iban, iban)
      |> Map.put(:bic, bic)
      |> Vex.valid?
    end
  end
end
