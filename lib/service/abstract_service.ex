defmodule FinTex.Service.AbstractService do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      def update_accounts {seq, accounts} do
        {acc, seq} = accounts
        |> Map.to_list
        |> Stream.filter(fn {_, account} -> apply(__MODULE__, :has_capability?, [seq, account]) end)
        |> Enum.map_reduce(seq, fn({key, acc}, seq) ->
          {seq, account} = apply(__MODULE__, :update_account, [seq, acc])
          {{key, account}, seq}
        end)

        {seq, Map.merge(accounts, acc |> Map.new)}
      end
    end
  end
end
