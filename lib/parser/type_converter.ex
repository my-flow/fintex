defmodule FinTex.Parser.TypeConverter do
  @moduledoc false

  alias FinTex.Parser.TypeMatcher
  alias FinTex.Parser.Lexer

  require TypeMatcher

  def string_to_type(segments) do
    segments
    |> Enum.map(fn
      [[name, pos, v, ref | t1] | t2] ->
        [[name, Lexer.to_number(pos), Lexer.to_number(v), Lexer.to_number(ref) | t1] | t2]
      [[name, pos, v | t1] | t2] ->
        [[name, Lexer.to_number(pos), Lexer.to_number(v) | t1] | t2]
    end)
    |> Enum.map fn s -> TypeMatcher.handle(s, :string_to_type) end
  end

  def type_to_string(segments, version) when is_binary(version) do
    segments
    |> Enum.map fn s -> TypeMatcher.handle(s, :type_to_string, version) end
  end

end
