defmodule FinTex.Command.GetAccountsInfo do
  @moduledoc false

  alias FinTex.Data.AccountHandler
  alias FinTex.Command.Synchronization
  alias FinTex.Service.AggregatedService


  def get_account_info(bank, client_system_id, tan_scheme_sec_func, credentials, options) do

    {seq, accounts} = bank
    |> Synchronization.synchronize(client_system_id, tan_scheme_sec_func, credentials, options)
    |> AggregatedService.check_capabilities_and_update_accounts

    %{} = Task.async(fn -> seq |> Synchronization.terminate end)

    accounts |> AccountHandler.to_list
  end
end
