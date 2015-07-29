defmodule FinTex.Segment.HIPINS do
  @moduledoc false

  def string_to_type(segment) when is_list(segment) do
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
  end
end
