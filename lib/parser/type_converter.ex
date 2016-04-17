defmodule FinTex.Parser.TypeConverter do
  @moduledoc false

  alias FinTex.Parser.Lexer


  def string_to_type(segments) do
    segments
    |> Stream.map(fn
      [[name, pos, v, nil | t1] | t2] ->
        [[name, Lexer.to_number(pos), Lexer.to_number(v) | t1] | t2]
      [[name, pos, v, ref | t1] | t2] ->
        [[name, Lexer.to_number(pos), Lexer.to_number(v), Lexer.to_number(ref) | t1] | t2]
      [[name, pos, v | t1] | t2] ->
        [[name, Lexer.to_number(pos), Lexer.to_number(v) | t1] | t2]
    end)
    |> Enum.map(fn s -> handle(s, :new) end)
  end


  def type_to_string(segments) when is_list(segments) do
    segments |> Enum.map(&type_to_string/1)
  end


  def type_to_string(%{segment: segment}), do: segment


  defp handle(segment, function) do
    [[name | _] | _] = segment

    module = Module.concat [Elixir, FinTex, Segment, String.upcase name]
    unless Code.ensure_loaded?(module) && function_exported?(module, function, 1) do
      module = Elixir.FinTex.Segment.Unknown
    end

    apply(module, function, [segment])
  end
end
