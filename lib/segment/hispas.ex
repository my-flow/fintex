defmodule FinTex.Segment.HISPAS do
  @moduledoc false

  def string_to_type(segment = [["HISPAS", _, 1, _] | _]) do
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
  end


  def string_to_type(segment = [["HISPAS", _, 2, _] | _]) do
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
  end

end
