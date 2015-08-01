defmodule FinTex.Segment.HIPINS do
  @moduledoc false

  defstruct [segment: nil]

  def new(segment) when is_list(segment) do
    %__MODULE__{segment:
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
          segment |> Enum.at(4) |> Enum.at(4),
          segment |> Enum.at(4) |> Enum.drop(5) |> Stream.chunk(2) |> Stream.map(fn [k, v] -> {k, v} end)
        ]
      ]
    }
  end
end


defimpl Inspect, for: FinTex.Segment.HIPINS do
  use FinTex.Helper.Inspect
end
