defmodule FinTex.Segment.HIRMG do
  @moduledoc false

  alias FinTex.Parser.Lexer

  def string_to_type(segment) when is_list(segment) do
    [
      segment |> Enum.at(0),
      segment |> Stream.drop(1) |> Stream.map &to_feedback/1
    ]
  end


  defp to_feedback(group) when is_list(group) do
    group
      |> List.update_at(0, &Lexer.to_digit/1)
  end
end
