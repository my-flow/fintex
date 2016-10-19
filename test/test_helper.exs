ExUnit.start()

defmodule FinTex.DataProvider do
  use FinTex

  @account_type :giro_account
  @account_number "00000"
  @subaccount_id nil
  @blz "10000000"
  @bank_name "Testbank"
  @currency "EUR"
  @iban "IT62T0538736850000000812451"
  @bic "BPMOIT22"
  @name "Girokonto"
  @owner "Max Mustermann"
  @balance nil
  @supported_payments nil
  @supported_tan_schemes []
  @preferred_tan_scheme "999"

  @url "https://example.org"
  @version "220"
  @client_system_id "0"

  @login "20248740"
  @client_id "200131"
  @pin "123456"


  def account do
    %{
      type: @account_type,
      account_number: @account_number,
      subaccount_id: @subaccount_id,
      blz: @blz,
      bank_name: @bank_name,
      currency: @currency,
      iban: @iban,
      bic: @bic,
      name: @name,
      owner: @owner,
      balance: @balance,
      supported_payments: @supported_payments,
      supported_tan_schemes: @supported_tan_schemes,
      preferred_tan_scheme: @preferred_tan_scheme
    }
  end


  def fintex do
    %FinTex{
      bank: bank,
      client_system_id: @client_system_id,
      tan_scheme_sec_func: @preferred_tan_scheme
    }
  end


  def bank do
    %{
      blz: @blz,
      url: @url,
      version: @version
    }
  end


  def credentials do
    %{
      login: @login,
      client_id: @client_id,
      pin: @pin
    }
  end


  def ibans do
    [System.cwd!, "test", "fixtures", "ibans.txt"]
    |> Path.join
    |> File.stream!([:read])
    |> Stream.map(&String.strip(&1))
  end


  def bics do
    [System.cwd!, "test", "fixtures", "bics.txt"]
    |> Path.join
    |> File.stream!([:read])
    |> Stream.map(&String.strip(&1))
  end
end
