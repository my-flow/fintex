defmodule FinTex.Service.AbstractService do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      alias FinTex.Data.AccountHandler

      import AccountHandler

      def update_accounts {seq, accounts} do
        AccountHandler.update_accounts {seq, accounts}, __MODULE__
      end
    end
  end
end
