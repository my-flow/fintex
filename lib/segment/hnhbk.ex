defmodule FinTex.Segment.HNHBK do
  @moduledoc false

  alias FinTex.Model.Dialog
  alias FinTex.Parser.Lexer

  defstruct []

  def create(_, d = %Dialog{}) do
    %{
      :bank       => bank,
      :dialog_id  => dialog_id,
      :message_no => message_no
    } = d

    [
      ["HNHBK", "?", 3],
      "",
      bank.version,
      dialog_id,
      message_no
    ]
  end


  def string_to_type(segment) when is_list(segment) do
    segment
      |> List.update_at(1, &Lexer.to_digit/1)
      |> List.update_at(2, &Lexer.to_number/1)
      |> List.update_at(3, &Lexer.to_id/1)
      |> List.update_at(4, &Lexer.to_number/1)
      |> List.update_at(5, &to_reference_message/1)
  end


  defp to_reference_message(group) when is_list(group) do
    group
      |> List.update_at(0, &Lexer.to_id/1)
      |> List.update_at(1, &Lexer.to_number/1)
  end

end
