defmodule FinTex.Segment.HISPAS do
  @moduledoc false

  defstruct [segment: nil]

  def new(segment = [["HISPAS", _, 1, _] | _]) do
    %__MODULE__{
      segment:
        [
          segment |> Enum.at(0),
          segment |> Enum.at(1),
          segment |> Enum.at(2),
          segment |> Enum.at(3),
          [
            segment |> Enum.at(4) |> Enum.at(0),
            segment |> Enum.at(4) |> Enum.at(1),
            segment |> Enum.at(4) |> Enum.at(2),

            segment |> Enum.at(4) |> Enum.drop(3)
          ]
        ]
    }
  end


  def new(segment = [["HISPAS", _, 2, _] | _]) do
    %__MODULE__{
      segment:
        [
          segment |> Enum.at(0),
          segment |> Enum.at(1),
          segment |> Enum.at(2),
          segment |> Enum.at(3),
          [
            segment |> Enum.at(4) |> Enum.at(0),
            segment |> Enum.at(4) |> Enum.at(1),
            segment |> Enum.at(4) |> Enum.at(2),
            segment |> Enum.at(4) |> Enum.at(3),

            segment |> Enum.at(4) |> Enum.drop(4)
          ]
        ]
    }
  end
end


defimpl Inspect, for: FinTex.Segment.HISPAS do
  use FinTex.Helper.Inspect
end
