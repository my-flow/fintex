defmodule FinTex.Parser.Tokenizer do
  @moduledoc false

  alias FinTex.Parser.Lexer

  require Record

  @type t :: record(:tokenization, tokens: [String.t] | String.t, escape_sequences: %{String.t => String.t})
  Record.defrecordp :tokenization,
    tokens: nil,
    escape_sequences: nil


  @spec split(String.t) :: [String.t]
  def split(raw) when is_binary(raw) do
    raw
    |> extract_binaries(Map.new)
    |> latin1_to_utf8
    |> split_segments
    |> replace_escape_sequences
  end


  @spec extract_binaries(String.t, map, non_neg_integer) :: t
  defp extract_binaries(raw, escape_sequences, ref_counter \\ 0) when is_binary(raw) and is_map(escape_sequences) and
    is_integer(ref_counter) do
    case ~r/@(\d+)@.*/Us |> Regex.run(raw, capture: :all_but_first) do

      [length] when is_binary(length) ->
        key = "--#{ref_counter}--"

        [_, binary_data, _] = length
        |> Lexer.escaped_binary
        |> Regex.run(raw, capture: :all_but_first)

        raw = length
        |> Lexer.escaped_binary
        |> Regex.replace(raw, "\\1#{key}\\3", global: false) # replace only first occurence

        escape_sequences = escape_sequences |> Map.put(key, binary_data)
        ref_counter = ref_counter + 1
        extract_binaries(raw, escape_sequences, ref_counter)

      _ ->
        tokenization(tokens: raw, escape_sequences: escape_sequences)
    end
  end


  @spec latin1_to_utf8(t) :: t
  defp latin1_to_utf8(tokenization = tokenization(tokens: tokens)) do
    tokenization(tokenization, tokens: Lexer.latin1_to_utf8(tokens))
  end


  @spec split_segments(t) :: t
  defp split_segments(tokenization = tokenization(tokens: tokens)) do
    tokens = tokens
    |> Lexer.split_segments

    tokenization(tokenization, tokens: tokens)
  end


  @spec replace_escape_sequences(t) :: [String.t]
  defp replace_escape_sequences(tokenization(tokens: tokens, escape_sequences: escape_sequences)) do
    escape_sequences
    |> Enum.reduce(tokens, fn ({k, v}, t) -> replace_escape_sequences(t, k, v) end)
  end


  @spec replace_escape_sequences([String.t] | String.t, String.pattern | Regex.t, String.t) :: [String.t] | String.t
  defp replace_escape_sequences(tokens, k, v) when is_list(tokens) do
    tokens |> Enum.map(&replace_escape_sequences(&1, k, v))
  end

  defp replace_escape_sequences(token, k, v) when is_binary(token) do
    token |> String.replace(k, v, global: false) # replace only first occurence
  end

  defp replace_escape_sequences(nil, _k, _v) do
    nil
  end
end
