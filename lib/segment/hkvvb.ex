defmodule FinTex.Segment.HKVVB do
  @moduledoc false

  alias FinTex.Model.Dialog

  defstruct [segment: nil]

  def new(
    s,
    %Dialog{
      bank:               bank,
      user_agent_name:    user_agent_name,
      user_agent_version: user_agent_version
    }) do

    v = case bank.version do
      "300" -> 3
      _     -> 2
    end

    %__MODULE__{s |
      segment:
        [
          ["HKVVB", "?", v],
          0,
          0,
          1,
          user_agent_name,
          user_agent_version
        ]
    }
  end
end


defimpl Inspect, for: FinTex.Segment.HKVVB do
  use FinTex.Helper.Inspect
end
