defmodule FinTex.Service.ServiceBehaviour do
  @moduledoc false

  alias FinTex.Model.Account
  alias FinTex.Command.Sequencer

  @callback has_capability?({Sequencer.t, %{String.t => Account.t}}) :: boolean
  @callback update_accounts({Sequencer.t, %{String.t => Account.t}}) :: {Sequencer.t, %{String.t => Account.t}}
end
