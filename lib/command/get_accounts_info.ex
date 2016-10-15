defmodule FinTex.Command.GetAccountsInfo do
  @moduledoc false

  alias FinTex.Controller.Synchronization
  alias FinTex.Data.AccountHandler
  alias FinTex.Helper.Command
  alias FinTex.Model.Bank
  alias FinTex.Model.Credentials
  alias FinTex.Service.AggregatedService

  use Command

  @type options :: []


  @spec get_account_info(FinTex.t, term, options) :: Enumerable.t | no_return
  def get_account_info(fintex, credentials, options) do

    %{bank: bank, tan_scheme_sec_func: tan_scheme_sec_func, client_system_id: client_system_id} = fintex
    %{} = bank = bank |> Bank.from_bank |> validate!
    %{} = credentials = credentials |> Credentials.from_credentials |> validate!

    {seq, accounts} = bank
    |> Synchronization.synchronize(client_system_id, tan_scheme_sec_func, credentials, options)
    |> AggregatedService.check_capabilities_and_update_accounts

    %{} = Task.async(fn -> seq |> Synchronization.terminate end)

    accounts |> AccountHandler.to_list
  end
end
