defmodule FinTex.Command.GetAccountsInfo do
  @moduledoc false

  alias FinTex.Command.Synchronization
  alias FinTex.Service.AggregatedService


  def get_account_info(bank, credentials, options) do

    {seq, accounts} = bank
    |> Synchronization.initialize_dialog(credentials, options)
    |> AggregatedService.update_accounts

    %{} = Task.async(fn -> seq |> Synchronization.terminate_dialog end)

    accounts |> Dict.values
  end
end
