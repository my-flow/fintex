defmodule FinTex.Connection.HTTPBody do
  @moduledoc false

  alias FinTex.Model.Dialog
  alias FinTex.Model.Response
  alias FinTex.Parser.Lexer
  alias FinTex.Parser.Serializer
  alias FinTex.Parser.TypeConverter


  def encode_body(segments, d = %Dialog{:bank => bank}) when is_list(segments) do
    segments
      |> TypeConverter.type_to_string(bank.version)
      |> Serializer.serialize(d)
      |> Base.encode64
  end


  def decode_body(response_body) when is_binary(response_body) do
    Response.new response_body
    |> Lexer.remove_newline
    |> Base.decode64!
    |> Serializer.deserialize
    |> TypeConverter.string_to_type
  end
end
