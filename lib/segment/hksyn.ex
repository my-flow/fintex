defmodule FinTex.Segment.HKSYN do
  @moduledoc false

  alias FinTex.Model.Dialog

  @synchronization_mode 0

  defstruct []

  def create(_, %Dialog{:bank => bank}) do
    v = case bank.version do
      "300" -> 3
      _     -> 2
    end

    [
      ["HKSYN", "?", v],
      @synchronization_mode
    ]
  end

end
