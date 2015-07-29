defmodule FinTex.Segment.HKTAB do
  @moduledoc false

  alias FinTex.Model.Dialog
  alias FinTex.Segment.Segment

  defstruct []

  import Segment

  def create(%__MODULE__{}, d = %Dialog{}) do
    v = max_version(d, __MODULE__)
    [
      ["HKTAB", "?", v],
      "0",
      "A"
    ]
  end
end
