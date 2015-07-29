defmodule FinTex.Segment.HKSPA do
  @moduledoc false

  alias FinTex.Model.Dialog
  alias FinTex.Segment.Segment

  defstruct []

  import Segment

  def create(_, d = %Dialog{}) do
    v = max_version(d, __MODULE__)
    [
      ["HKSPA", "?", v]
    ]
  end

end
