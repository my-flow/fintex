defmodule FinTex.Segment.HNHBS do
  @moduledoc false

  alias FinTex.Helper.Conversion
  alias FinTex.Model.Dialog

  defstruct [segment: nil]

  def new(s, %Dialog{message_no: message_no}) do
    %__MODULE__{s |
      segment:
        [
          ["HNHBS", "?", 1],
          message_no
        ]
    }
  end


  def new(segment) when is_list(segment) do
    %__MODULE__{
      segment:
        segment
        |> List.update_at(1, &Conversion.to_number/1)
    }
  end
end


defimpl Inspect, for: FinTex.Segment.HNHBS do
  use FinTex.Helper.Inspect
end
