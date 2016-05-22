defmodule FinTex.User.FinCredentialsTest do
  alias FinTex.DataProvider
  alias FinTex.Model.Credentials
  alias FinTex.User.FinCredentials
  use ExUnit.Case
  use FinTex


  test "it should accept a struct" do
    credentials = DataProvider.credentials |> FinCredentials.from_credentials

    assert nil != credentials
    assert credentials.login == credentials |> Credentials.login
    assert credentials.client_id == credentials |> Credentials.client_id
    assert credentials.pin == credentials |> Credentials.pin
  end


  test "it should accept a map" do
    credentials = DataProvider.credentials

    assert nil != credentials
    assert credentials.login == credentials |> Credentials.login
    assert credentials.client_id == credentials |> Credentials.client_id
    assert credentials.pin == credentials |> Credentials.pin
  end


  test "it should accept a keyword" do
    credentials = DataProvider.credentials |> Enum.to_list

    assert nil != credentials
    assert credentials[:login] == credentials |> Credentials.login
    assert credentials[:client_id] == credentials |> Credentials.client_id
    assert credentials[:pin] == credentials |> Credentials.pin
  end


  test "it should set up the client ID" do
    credentials = DataProvider.credentials |> Map.put(:client_id, nil) |> FinCredentials.from_credentials

    assert nil != credentials
    assert credentials.login == credentials |> Credentials.login
    assert credentials.login == credentials |> Credentials.client_id
    assert credentials.pin == credentials |> Credentials.pin
  end


  test "it should validate login" do
    credentials = DataProvider.credentials |> FinCredentials.from_credentials

    refute %FinCredentials{credentials | login: ""}
    |> FinCredentials.from_credentials
    |> Vex.valid?
  end


  test "it should validate PIN" do
    credentials = DataProvider.credentials |> FinCredentials.from_credentials

    refute %FinCredentials{credentials | pin: ""} |> Vex.valid?
  end
end
