defmodule FinTex.Segment.HKSPA do
  @moduledoc false

  alias FinTex.Model.Dialog
  alias FinTex.Helper.Segment

  defstruct [segment: nil]

  import Segment

  def new(_, d = %Dialog{}) do
    v = max_version(d, __MODULE__)
    %__MODULE__{
      segment:
        [
          ["HKSPA", "?", v]
        ]
    }
  end

end


defimpl Inspect, for: FinTex.Segment.HKSPA do
  use FinTex.Helper.Inspect
end
