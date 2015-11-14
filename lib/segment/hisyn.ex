defmodule FinTex.Segment.HISYN do
  @moduledoc false

  defstruct [segment: nil]

  def new(segment) when is_list(segment) do
    %__MODULE__{
      segment:
        [
          segment |> Enum.at(0)
          | segment |> Enum.at(1) |> String.split("+")
        ]
    }
  end
end


defimpl Inspect, for: FinTex.Segment.HISYN do
  use FinTex.Helper.Inspect
end
