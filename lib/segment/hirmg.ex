defmodule FinTex.Segment.HIRMG do
  @moduledoc false

  alias FinTex.Parser.Lexer

  defstruct [segment: nil]

  def new(segment) when is_list(segment) do
    %__MODULE__{
      segment: 
        [
          segment |> Enum.at(0),
          segment |> Stream.drop(1) |> Enum.map &to_feedback/1
        ]
    }
  end


  defp to_feedback(group) when is_list(group) do
    group
      |> List.update_at(0, &Lexer.to_digit/1)
  end
end


defimpl Inspect, for: FinTex.Segment.HIRMG do
  use FinTex.Helper.Inspect
end
