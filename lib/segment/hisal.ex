defmodule FinTex.Segment.HISAL do
  @moduledoc false

  alias FinTex.Parser.Lexer

  def string_to_type(segment) when is_list(segment) do
    [
      segment |> Enum.at(0),
      segment |> Enum.at(1),
      segment |> Enum.at(2),
      segment |> Enum.at(3),
      [
        segment |> Enum.at(4) |> Enum.at(0),
        segment |> Enum.at(4) |> Enum.at(1) |> Lexer.to_amount,
        segment |> Enum.at(4) |> Enum.at(2),
        segment |> Enum.at(4) |> Enum.at(3),
        segment |> Enum.at(4) |> Enum.at(4)
      ]
      | segment |> Enum.drop(5)
    ]
    |> List.update_at(6, fn [hd | tl] -> [hd |> Lexer.to_amount | tl] end)
    |> List.update_at(7, fn [hd | tl] -> [hd |> Lexer.to_amount | tl] end)
  end

end
