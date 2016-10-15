defmodule FinTex.Service.AbstractService do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      alias FinTex.Model.Account
      alias FinTex.Controller.Sequencer
      alias FinTex.Service.ServiceBehaviour

      @behaviour ServiceBehaviour

      # Optional Callback with default implementation
      def update_accounts({seq, accounts}) do
        {seq, accounts}
      end

      defoverridable [update_accounts: 1]


      def check_capabilities_and_update_accounts {seq, accounts} do
        check_capabilities_and_update_accounts {seq, accounts}, __MODULE__
      end

      @spec check_capabilities_and_update_accounts({Sequencer.t, %{String.t => Account.t}}, module)
        :: {Sequencer.t, %{String.t => Account.t}}
      def check_capabilities_and_update_accounts {seq, accounts}, module do
        {:module, module} = Code.ensure_loaded(module)
        if function_exported?(module, :update_account,  2) do
            {acc, seq} = accounts
            |> Map.to_list
            |> Stream.filter(fn entry -> apply(module, :has_capability?, [{seq, [entry] |> Map.new}]) end)
            |> Enum.map_reduce(seq, fn({key, acc}, seq) ->
              {seq, account} = apply(module, :update_account, [seq, acc])
              {{key, account}, seq}
            end)
            {seq, Map.merge(accounts, acc |> Map.new)}
        else
          if function_exported?(module, :update_accounts, 1) do
            if apply(module, :has_capability?, [{seq, accounts}]) do
              apply(module, :update_accounts, [{seq, accounts}])
            else
              {seq, accounts}
            end
          end
        end
      end
    end
  end
end
