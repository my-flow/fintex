defmodule FinTex.Segment.HISAL do
  @moduledoc false

  alias FinTex.Parser.Lexer

  defstruct [segment: nil]

  def new(segment) when is_list(segment) do
    %__MODULE__{
      segment:
        [
          segment |> Enum.at(0),
          segment |> Enum.at(1),
          segment |> Enum.at(2),
          segment |> Enum.at(3),
          [
            segment |> Enum.at(4) |> Enum.at(0),
            segment |> Enum.at(4) |> Enum.at(1) |> Lexer.to_amount |> Decimal.new,
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
    [hd |> Lexer.to_amount |> Decimal.new | tl]
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
