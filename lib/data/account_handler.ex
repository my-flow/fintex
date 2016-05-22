defmodule FinTex.Data.AccountHandler do
  @moduledoc false

  alias FinTex.User.FinAccount



  @spec to_accounts_map(Enumerable.t) :: %{String.t => FinAccount.t}
  def to_accounts_map(accounts) do
    accounts |> Map.new(fn account -> {FinAccount.key(account), account} end)
  end


  @spec to_list(%{String.t => FinAccount.t}) :: Enumerable.t
  def to_list(accounts) do
    accounts
    |> Map.values
    |> Enum.sort(fn account1, account2 ->
        account1 |> FinAccount.key |> String.length <= account2 |> FinAccount.key |> String.length &&
        account1 |> FinAccount.key <= account2 |> FinAccount.key
      end)
  end


  @spec find_account(%{String.t => FinAccount.t}, FinAccount.t) :: FinAccount.t | nil
  def find_account(accounts, account) do
    accounts
    |> Enum.reduce(nil, fn({_, value}, acc) -> find(value, account, acc) end)
  end


  defp find(
    %FinAccount{iban: iban} = account,
    %FinAccount{iban: iban},
    _
  ) when iban != nil
  do
    account
  end


  defp find(
    %FinAccount{account_number: account_number, subaccount_id: subaccount_id} = account,
    %FinAccount{account_number: account_number, subaccount_id: subaccount_id},
    _
  ) when account_number != nil
  do
    account
  end


  defp find(_, _, acc), do: acc
end
