defmodule FinTex.Segment.HICSES do
  @moduledoc false

  alias FinTex.Helper.Conversion

  defstruct [segment: nil]

  def new(segment) when is_list(segment) do
    %__MODULE__{
      segment:
        [
          segment |> Enum.at(0),
          segment |> Enum.at(1) |> Conversion.to_number,
          segment |> Enum.at(2) |> Conversion.to_number,
          segment |> Enum.at(3),
          [
            segment |> Enum.at(4) |> Enum.at(0) |> Conversion.to_number,
            segment |> Enum.at(4) |> Enum.at(1) |> Conversion.to_number
          ]
          | segment |> Enum.drop(5)
        ]
    }
  end
end


defimpl Inspect, for: FinTex.Segment.HICSES do
  use FinTex.Helper.Inspect
end
