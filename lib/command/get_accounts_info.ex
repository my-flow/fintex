defmodule FinTex.Command.GetAccountsInfo do
  @moduledoc false

  alias FinTex.Command.Synchronization
  alias FinTex.Data.AccountHandler
  alias FinTex.Service.AggregatedService

  import AccountHandler

  def get_account_info(bank, client_system_id, tan_scheme_sec_func, credentials, options) do

    {seq, accounts} = bank
    |> Synchronization.synchronize(client_system_id, tan_scheme_sec_func, credentials, options)
    |> AggregatedService.update_accounts

    %{} = Task.async(fn -> seq |> Synchronization.terminate end)

    accounts |> to_list
  end
end
