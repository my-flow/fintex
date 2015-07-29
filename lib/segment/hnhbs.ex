defmodule FinTex.Segment.HNHBS do
  @moduledoc false

  alias FinTex.Model.Dialog
  alias FinTex.Parser.Lexer

  defstruct []

  def create(_, %Dialog{:message_no => message_no}) do
    [
      ["HNHBS", "?", 1],
      message_no
    ]
  end


  def string_to_type(segment) when is_list(segment) do
    segment
      |> List.update_at(1, &Lexer.to_number/1)
  end
end
