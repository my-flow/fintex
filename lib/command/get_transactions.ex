defmodule FinTex.Command.GetTransactions do
  @moduledoc false

  alias FinTex.Command.AbstractCommand
  alias FinTex.Command.Sequencer
  alias FinTex.Command.Synchronization
  alias FinTex.Model.Transaction
  alias FinTex.Parser.Lexer
  alias FinTex.Segment.HKKAZ
  alias FinTex.Segment.HNHBK
  alias FinTex.Segment.HNHBS
  alias FinTex.Segment.HNSHA
  alias FinTex.Segment.HNSHK

  use AbstractCommand
  use MT940


  def get_transactions(bank, account, login, client_id, pin, options)
  when is_binary(login) and is_binary(client_id) and is_binary(pin) do

    {seq, _} = Synchronization.initialize_dialog(bank, login, client_id, pin)

    {seq, transactions} = seq |> check_transactions(account, [])

    %{} = Task.async(fn -> seq |> Synchronization.terminate_dialog end)

    transactions
  end


  defp check_transactions(seq, account, transactions, start_point \\ nil) do

    request_segments = [
      %HNHBK{},
      %HNSHK{},
      %HKKAZ{account: account, start_point: start_point},
      %HNSHA{},
      %HNHBS{}
    ]

    {:ok, response} = seq |> Sequencer.call_http(request_segments)

    transactions = transactions |> Stream.concat(response[:HIKAZ] |> Stream.flat_map(fn s -> s |> Enum.at(1) |> transform end))

    start_point = response[:HIRMS]
    |> messages
    |> Stream.filter_map(fn [code | _] -> code === 3040 end, fn [_code, _ref, _text, start_point] -> start_point end)
    |> Enum.at(0)

    warn "Start point: #{inspect start_point}"

    seq = seq |> Sequencer.inc

    case start_point do
      nil -> {seq, transactions}
      _   -> check_transactions(seq, account, transactions, start_point)
    end
  end


  defp transform(raw) when is_binary(raw) do
    raw
    |> String.codepoints
    |> Enum.map(&Lexer.latin1_to_utf8/1)
    |> to_string
    |> parse!
    |> Stream.flat_map(&MT940.CustomerStatementMessage.statement_lines/1)
    |> Stream.map(&Transaction.from_statement/1)
  end
end
