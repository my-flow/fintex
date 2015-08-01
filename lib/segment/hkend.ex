defmodule FinTex.Segment.HKEND do
  @moduledoc false

  alias FinTex.Model.Dialog

  defstruct [segment: nil]

  def new(_, %Dialog{:dialog_id => dialog_id}) do
    %__MODULE__{
      segment:
        [
          ["HKEND", "?", 1],
          dialog_id
        ]
    }
  end
end


defimpl Inspect, for: FinTex.Segment.HKEND do
  use FinTex.Helper.Inspect
end
