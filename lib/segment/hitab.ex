defmodule FinTex.Segment.HITAB do
  @moduledoc false

  alias FinTex.Model.TANMedium

  defstruct [segment: nil]


  def to_tan_media(segment = [["HITAB", _, _ | _] | _]) do
    for medium <- segment |> Enum.drop(2),
        do: %TANMedium{
              name: medium |> Enum.at(12),
              format: medium |> Enum.at(0) |> to_format
            }
  end


  defp to_format("A"), do: :all
  defp to_format("L"), do: :text
  defp to_format("G"), do: :hhd
  defp to_format("M"), do: :text
  defp to_format("S"), do: :hhd
end


defimpl Inspect, for: FinTex.Segment.HITAB do
  use FinTex.Helper.Inspect
end
