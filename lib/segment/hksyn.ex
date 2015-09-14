defmodule FinTex.Segment.HKSYN do
  @moduledoc false

  alias FinTex.Model.Dialog

  @synchronization_mode 0

  defstruct [segment: nil]

  def new(_, %Dialog{bank: bank}) do
    v = case bank.version do
      "300" -> 3
      _     -> 2
    end

    %__MODULE__{
      segment:
        [
          ["HKSYN", "?", v],
          @synchronization_mode
        ]
    }
  end
end


defimpl Inspect, for: FinTex.Segment.HKSYN do
  use FinTex.Helper.Inspect
end
