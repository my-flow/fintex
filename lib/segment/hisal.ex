defmodule FinTex.Segment.HISAL do
  @moduledoc false

  alias FinTex.Helper.Amount

  defstruct [segment: nil]

  def new(segment) when is_list(segment) do

    sign = case segment |> Enum.at(4) |> Enum.at(0) do
      "C" -> +1
      "D" -> -1
    end

    %__MODULE__{
      segment:
        [
          segment |> Enum.at(0),
          segment |> Enum.at(1),
          segment |> Enum.at(2),
          segment |> Enum.at(3),
          [
            segment |> Enum.at(4) |> Enum.at(0),
            segment |> Enum.at(4) |> Enum.at(1) |> Amount.parse(sign),
            segment |> Enum.at(4) |> Enum.at(2),
            segment |> Enum.at(4) |> Enum.at(3),
            segment |> Enum.at(4) |> Enum.at(4)
          ]
          | segment |> Enum.drop(5)
        ]
        |> List.update_at(6, &to_amount/1)
        |> List.update_at(7, &to_amount/1)
        |> List.update_at(8, &to_amount/1)
    }
  end


  defp to_amount [hd | tl] do
    [hd |> Amount.parse | tl]
  end

  defp to_amount nil do
    []
  end

  defp to_amount elem do
    elem
  end
end


defimpl Inspect, for: FinTex.Segment.HISAL do
  use FinTex.Helper.Inspect
end
