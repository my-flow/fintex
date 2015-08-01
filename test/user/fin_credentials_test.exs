defmodule FinTex.User.FinCredentialsTest do
  alias FinTex.Model.Credentials
  alias FinTex.User.FinCredentials
  use ExUnit.Case
  use FinTex

  @login "20248740"
  @client_id "200131"
  @pin "123456"


  test "it should create a new struct" do
    credentials = %FinCredentials{login: @login, client_id: @client_id, pin: @pin} |> FinCredentials.from_credentials
    assert nil != credentials
    assert @login == credentials |> Credentials.login
    assert @client_id == credentials |> Credentials.client_id
    assert @pin == credentials |> Credentials.pin
  end


  test "it should set up the client ID" do
    credentials = %FinCredentials{login: @login, client_id: nil, pin: @pin} |> FinCredentials.from_credentials
    assert nil != credentials
    assert @login == credentials |> Credentials.login
    assert @login == credentials |> Credentials.client_id
    assert @pin == credentials |> Credentials.pin
  end


  test "it should validate login" do
    refute %FinCredentials{login: "", client_id: @client_id, pin: @pin} |> Vex.valid?
  end


  test "it should validate PIN" do
    refute %FinCredentials{login: @login, client_id: @client_id, pin: ""} |> Vex.valid?
  end
end
