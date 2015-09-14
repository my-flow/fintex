defmodule FinTex.Segment.HITAB do
  @moduledoc false

  defstruct [segment: nil]


  def to_medium_name(segment = [["HITAB", _, 4 | _] | _]) do
    segment |> Enum.at(2) |> Enum.at(12)
  end
end


defimpl Inspect, for: FinTex.Segment.HITAB do
  use FinTex.Helper.Inspect
end
