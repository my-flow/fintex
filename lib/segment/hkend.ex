defmodule FinTex.Segment.HKEND do
  @moduledoc false

  alias FinTex.Model.Dialog

  defstruct []

  def create(_, %Dialog{:dialog_id => dialog_id}) do
    [
      ["HKEND", "?", 1],
      dialog_id
    ]
  end

end
