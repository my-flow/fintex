defmodule FinTex.Segment.HNVSD do
  @moduledoc false

  alias FinTex.Parser.Lexer

  defstruct [:tail, segment: nil]

  def new(s = %__MODULE__{tail: tail}, _) do
    %__MODULE__{s |
      segment:
        [
          ["HNVSD", 999, 1],
          tail |> Lexer.join_segments |> Lexer.encode_binary
        ]
    }
  end
end


defimpl Inspect, for: FinTex.Segment.HNVSD do
  use FinTex.Helper.Inspect
end
