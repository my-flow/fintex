defmodule FinTex.Connection.HTTPBody do
  @moduledoc false

  alias FinTex.Model.Dialog
  alias FinTex.Model.Response
  alias FinTex.Parser.Serializer
  alias FinTex.Parser.TypeConverter


  def encode_body(segments, d = %Dialog{}) when is_list(segments) do
    segments
    |> TypeConverter.type_to_string
    |> Serializer.serialize(d)
    |> Base.encode64
  end


  def decode_body(response_body) when is_binary(response_body) do
    result = response_body
    |> Base.decode64(ignore: :whitespace, padding: false)

    case result do
      :error -> raise FinTex.Error, reason: "could not base 64 decode server response \"#{response_body}\""
      {:ok, string} -> string
        |> Serializer.deserialize
        |> TypeConverter.string_to_type
        |> Response.new
    end
  end
end
