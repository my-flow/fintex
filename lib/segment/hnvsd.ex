defmodule FinTex.Segment.HNVSD do
  @moduledoc false

  alias FinTex.Parser.Lexer

  defstruct [:tail]

  def create(%__MODULE__{tail: tail}, _) do
    [
      ["HNVSD", 999, 1],
      tail |> Lexer.join_segments |> Lexer.encode_binary
    ]
  end

end
