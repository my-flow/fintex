defmodule FinTex.Command.GetTransactions do
  @moduledoc false

  alias FinTex.Controller.Sequencer
  alias FinTex.Controller.Synchronization
  alias FinTex.Helper.Command
  alias FinTex.Model.Account
  alias FinTex.Model.Bank
  alias FinTex.Model.Credentials
  alias FinTex.Model.Transaction
  alias FinTex.Parser.Lexer
  alias FinTex.Segment.HKKAZ
  alias FinTex.Segment.HNHBK
  alias FinTex.Segment.HNHBS
  alias FinTex.Segment.HNSHA
  alias FinTex.Segment.HNSHK
  alias MT940.CustomerStatementMessage

  use Command
  use MT940

  @type date_time :: DateTime.t
  @type options :: []


  @spec get_transactions(FinTex.t, term, term, date_time | nil, date_time | nil, options) ::
    Enumerable.t | no_return
  def get_transactions(fintex, credentials, account, from, to, options) do

    %{bank: bank, tan_scheme_sec_func: tan_scheme_sec_func, client_system_id: client_system_id} = fintex
    bank = bank |> Bank.from_bank |> validate!
    credentials = credentials |> Credentials.from_credentials |> validate!
    account = account |> Account.from_account |> validate!

    {seq, _} = Synchronization.synchronize(bank, client_system_id, tan_scheme_sec_func, credentials, options)

    {seq, transactions} = seq |> check_transactions(account, [], from, to)

    %{} = Task.async(fn -> seq |> Synchronization.terminate end)

    transactions
  end


  defp check_transactions(seq, account, transactions, from, to, start_point \\ nil) do

    request_segments = [
      %HNHBK{},
      %HNSHK{},
      %HKKAZ{account: account, from: from, to: to, start_point: start_point},
      %HNSHA{},
      %HNHBS{}
    ]

    {:ok, response} = seq |> Sequencer.call_http(request_segments)

    transactions = transactions
    |> Stream.concat(response[:HIKAZ] |> Stream.flat_map(fn s -> s |> Enum.at(1) |> transform(true)  end))
    |> Stream.concat(response[:HIKAZ] |> Stream.flat_map(fn s -> s |> Enum.at(2) |> transform(false) end))

    start_point = response[:HIRMS]
    |> to_messages
    |> Stream.filter_map(fn [code | _] -> code === 3040 end, fn [_code, _ref, _text, start_point] -> start_point end)
    |> Enum.at(0)

    seq = seq |> Sequencer.inc

    case start_point do
      nil -> {seq, transactions}
      _   -> check_transactions(seq, account, transactions, from, to, start_point)
    end
  end


  defp transform(raw, booked) when is_binary(raw) and is_boolean(booked) do
    raw
    |> Lexer.latin1_to_utf8
    |> parse!
    |> Stream.flat_map(&CustomerStatementMessage.statement_lines/1)
    |> Stream.map(fn s -> %{Transaction.from_statement(s) | booked: booked} end)
  end


  defp transform(nil, _) do
    []
  end

end
