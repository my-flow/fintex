defmodule FinTex.Service.ServiceBehaviour do
  @moduledoc false

  alias FinTex.Model.Account
  alias FinTex.Command.Sequencer

  @callback has_capability?(Sequencer.t, Account.t) :: boolean
  @callback update_accounts({any, %{String.t => Account.t}}) :: {any, %{String.t => Account.t}}
end 
