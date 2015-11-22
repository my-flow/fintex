defmodule FinTex.Service.ServiceBehaviour do
  @moduledoc false

  alias FinTex.Model.Account
  alias FinTex.Command.Sequencer

  use Behaviour

  defcallback has_capability?(Sequencer.t, Account.t)
  defcallback update_accounts {any, [Account.t]} :: {any, [Account.t]}
end 
