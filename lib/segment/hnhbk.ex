defmodule FinTex.Segment.HNHBK do
  @moduledoc false

  alias FinTex.Model.Dialog
  alias FinTex.Parser.Lexer

  defstruct [segment: nil]

  def new(s, d = %Dialog{}) do
    %{
      bank:       bank,
      dialog_id:  dialog_id,
      message_no: message_no
    } = d

    %__MODULE__{ s |
      segment:
        [
          ["HNHBK", "?", 3],
          "$SIZE",
          bank.version,
          dialog_id,
          message_no
        ]
    }
  end


  def new(segment) when is_list(segment) do
    %__MODULE__{
      segment:
        segment
        |> List.update_at(1, &Lexer.to_digit/1)
        |> List.update_at(2, &Lexer.to_number/1)
        |> List.update_at(3, &Lexer.to_id/1)
        |> List.update_at(4, &Lexer.to_number/1)
        |> List.update_at(5, &to_reference_message/1)
      }
  end


  defp to_reference_message(group) when is_list(group) do
    group
    |> List.update_at(0, &Lexer.to_id/1)
    |> List.update_at(1, &Lexer.to_number/1)
  end

end


defimpl Inspect, for: FinTex.Segment.HNHBK do
  use FinTex.Helper.Inspect
end
