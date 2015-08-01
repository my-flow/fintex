defmodule FinTex.Segment.HITAB do
  @moduledoc false

  alias FinTex.Model.TANScheme

  defstruct [segment: nil]


  def to_tan_scheme(segment = [["HITAB", _, 4 | _] | _], tan_scheme) do
    %TANScheme{ tan_scheme | medium_name:  segment |> Enum.at(2) |> Enum.at(12) }
  end
end


defimpl Inspect, for: FinTex.Segment.HITAB do
  use FinTex.Helper.Inspect
end
