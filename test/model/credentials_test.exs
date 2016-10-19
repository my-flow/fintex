defmodule FinTex.Model.CredentialsTest do
  alias FinTex.DataProvider
  alias FinTex.Model.Credentials
  alias FinTex.User.FinCredentials
  use ExUnit.Case
  use FinTex


  test "it should accept a struct" do
    credentials = DataProvider.credentials |> Credentials.from_fin_credentials

    assert nil != credentials
    assert credentials.login == credentials |> FinCredentials.login
    assert credentials.client_id == credentials |> FinCredentials.client_id
    assert credentials.pin == credentials |> FinCredentials.pin
  end


  test "it should accept a map" do
    credentials = DataProvider.credentials

    assert nil != credentials
    assert credentials.login == credentials |> FinCredentials.login
    assert credentials.client_id == credentials |> FinCredentials.client_id
    assert credentials.pin == credentials |> FinCredentials.pin
  end


  test "it should accept a keyword" do
    credentials = DataProvider.credentials |> Enum.to_list

    assert nil != credentials
    assert credentials[:login] == credentials |> FinCredentials.login
    assert credentials[:client_id] == credentials |> FinCredentials.client_id
    assert credentials[:pin] == credentials |> FinCredentials.pin
  end


  test "it should set up the client ID" do
    credentials = DataProvider.credentials |> Map.put(:client_id, nil) |> Credentials.from_fin_credentials

    assert nil != credentials
    assert credentials.login == credentials |> FinCredentials.login
    assert credentials.login == credentials |> FinCredentials.client_id
    assert credentials.pin == credentials |> FinCredentials.pin
  end


  test "it should validate login" do
    credentials = DataProvider.credentials |> Credentials.from_fin_credentials

    refute %Credentials{credentials | login: ""}
    |> Credentials.from_fin_credentials
    |> Vex.valid?
  end


  test "it should validate PIN" do
    credentials = DataProvider.credentials |> Credentials.from_fin_credentials

    refute %Credentials{credentials | pin: ""} |> Vex.valid?
  end
end
