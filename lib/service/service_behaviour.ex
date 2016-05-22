defmodule FinTex.Service.ServiceBehaviour do
  @moduledoc false

  alias FinTex.Command.Sequencer

  @callback has_capability?({Sequencer.t, %{String.t => FinAccount.t}}) :: boolean
  @callback update_accounts({Sequencer.t, %{String.t => FinAccount.t}}) :: {Sequencer.t, %{String.t => FinAccount.t}}
end
