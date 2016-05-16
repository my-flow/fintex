defmodule FinTex.Segment.HNHBS do
  @moduledoc false

  alias FinTex.Model.Dialog
  alias FinTex.Parser.Lexer

  defstruct [segment: nil]

  def new(s, %Dialog{message_no: message_no}) do
    %__MODULE__{s |
      segment:
        [
          ["HNHBS", "?", 1],
          message_no
        ]
    }
  end


  def new(segment) when is_list(segment) do
    %__MODULE__{
      segment:
        segment
        |> List.update_at(1, &Lexer.to_number/1)
    }
  end
end


defimpl Inspect, for: FinTex.Segment.HNHBS do
  use FinTex.Helper.Inspect
end
