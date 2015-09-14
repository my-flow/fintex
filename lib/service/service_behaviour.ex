defmodule FinTex.Service.ServiceBehaviour do
  @moduledoc false

  alias FinTex.Model.Account

  use Behaviour

  defcallback has_capability?(Account.t)
  defcallback update_accounts {any, [Account.t]} :: {any, [Account.t]}
end 
