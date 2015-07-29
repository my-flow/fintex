defmodule FinTex.Command.GetAccountsInfo do
  @moduledoc false

  alias FinTex.Command.AbstractCommand
  alias FinTex.Command.GetAccountBalance
  alias FinTex.Command.Sequencer
  alias FinTex.Command.Synchronization
  alias FinTex.Model.Account
  alias FinTex.Segment.HNHBK
  alias FinTex.Segment.HNSHK
  alias FinTex.Segment.HNSHA
  alias FinTex.Segment.HKSPA
  alias FinTex.Segment.HNHBS

  use AbstractCommand


  def get_account_info(bank, login, client_id, pin, options)
  when is_binary(login) and is_binary(client_id) and is_binary(pin) do

    {seq, accounts} = Synchronization.initialize_dialog(bank, login, client_id, pin)

    request_segments = [
      %HNHBK{},
      %HNSHK{},
      %HKSPA{},
      %HNSHA{},
      %HNHBS{}
    ]

    {:ok, response} = seq |> Sequencer.call_http(request_segments)

    accounts = add_sepa_data(accounts, response)

    seq = seq |> Sequencer.inc

    {acc, seq} = accounts
    |> Dict.to_list
    |> Stream.filter(fn {_, %Account{:supported_transactions => supported_transactions}} ->
        supported_transactions |> Enum.member?("HKSAL")
      end)
    |> Enum.map_reduce(seq, fn({key, acc}, seq) ->
      account = seq |> GetAccountBalance.get_account_balance(acc)
      {{key, account}, seq |> Sequencer.inc}
    end)

    %{} = Task.async(fn -> seq |> Synchronization.terminate_dialog end)

    accounts |> Dict.merge(acc) |> Dict.values
  end


  defp add_sepa_data(accounts, response) do
    response[:HISPA]
    |> Enum.at(0)
    |> Stream.drop(1)
    |> Stream.filter(fn info -> Enum.at(info, 0) === "J" end)
    |> Stream.map(fn info ->
        account = accounts |> Dict.get(Enum.at(info, 3))
        account = %Account{account |
          iban: Enum.at(info, 1),
          bic:  Enum.at(info, 2)
        }
        %{account_number: account_number} = account
        {account_number, account}
       end)
    |> Enum.into(accounts)
  end

end
