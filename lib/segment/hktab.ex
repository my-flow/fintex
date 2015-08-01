defmodule FinTex.Segment.HKTAB do
  @moduledoc false

  alias FinTex.Model.Dialog
  alias FinTex.Helper.Segment

  defstruct [segment: nil]

  import Segment

  def new(%__MODULE__{}, d = %Dialog{}) do
    v = max_version(d, __MODULE__)
    %__MODULE__{
      segment:
        [
          ["HKTAB", "?", v],
          "0",
          "A"
        ]
    }
  end
end


defimpl Inspect, for: FinTex.Segment.HKTAB do
  use FinTex.Helper.Inspect
end
