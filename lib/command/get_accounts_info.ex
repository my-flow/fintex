defmodule FinTex.Command.GetAccountsInfo do
  @moduledoc false

  alias FinTex.Command.AbstractCommand
  alias FinTex.Command.GetAccountBalance
  alias FinTex.Command.Sequencer
  alias FinTex.Command.Synchronization
  alias FinTex.Model.Account

  use AbstractCommand


  def get_account_info(bank, credentials, options) do

    {seq, accounts} = Synchronization.initialize_dialog(bank, credentials, options)

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
end
