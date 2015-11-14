defmodule FinTex.Parser.Lexer do
  @moduledoc false

  alias FinTex.Helper.Amount
  require Record

  Record.defrecordp :tokenization,
    tokens: nil,
    escape_sequences: nil

  @control_chars ["?", "+", ":", "'", "@"]


  def segment_end, do: "(?<!\\?)'"
  def escaped_binary(length), do: Regex.compile!("\\A(.*)@#{length}@(.{#{length}})(.*)\\z", "msr")
  def escaped_binary, do: Regex.compile!("\\A(.*)@\\d+@.*\\z", "msr")


  def encode_binary(raw) when is_binary(raw) do
    "@#{String.length(raw)}@#{raw}"
  end


  def escaped_binary?(raw) do
    escaped_binary |> Regex.match?(raw)
  end


  def remove_newline(string) when is_binary(string) do
    ~r(\R) |> Regex.replace(string, "")
  end


  def split(raw) do
    raw
    |> extract_binaries(HashDict.new)
    |> latin1_to_utf8
    |> split_segments
    |> replace_escape_sequences
  end


  defp extract_binaries(raw, dict) do
    case Regex.run(~r/@(\d+)@.*/sr, raw, capture: :all_but_first) do
      [length] ->
        ref_counter = round(:random.uniform * 100_000_000)
        marker = "--#{ref_counter}--"

        [_, binary_data, _] = length
        |> escaped_binary
        |> Regex.run(raw, capture: :all_but_first)

        raw = length
        |> escaped_binary
        |> Regex.replace(raw, "\\1#{marker}\\3", global: false) # replace only first occurence

        dict = dict |> Dict.put(marker, binary_data)
        extract_binaries(raw, dict)
      _ ->
        tokenization(tokens: raw, escape_sequences: dict)
    end
  end


  def latin1_to_utf8(tokenization = tokenization(tokens: tokens)) do
    tokens = tokens
    |> String.codepoints
    |> Enum.map(&latin1_to_utf8/1)
    |> to_string

    tokenization(tokenization, tokens: tokens)
  end


  # convert charset from ISO 8859-1 to UTF-8
  def latin1_to_utf8(<<c>>) do
    cond do
      c >= 196 && c <= 252 -> <<195, c - 64>>
      true                 -> <<c>>
    end
  end


  def latin1_to_utf8(c), do: c


  # convert charset from UTF-8 to ISO 8859-1
  def to_latin1(string) when is_binary(string) do
    string
    |> String.codepoints
    |> Enum.map(&utf8_to_latin1/1)
    |> :binary.list_to_bin
  end


  defp utf8_to_latin1(x = <<195, c>>) do
    cond do
      c >= 132 && c <= 188 -> <<c + 64>>
      true                 -> x
    end
  end


  defp utf8_to_latin1(c), do: c


  defp replace_escape_sequences(tokenization(tokens: tokens, escape_sequences: escape_sequences)) do
    escape_sequences
    |> Enum.reduce(tokens, fn ({k, v}, t) -> replace_escape_sequences(t, k, v) end) # replace only first occurence
  end


  defp replace_escape_sequences(tokens, k, v) when is_list(tokens) do
    tokens |> Enum.map(&replace_escape_sequences(&1, k, v))
  end


  defp replace_escape_sequences(token, k, v) when is_binary(token) do
    token |> String.replace(k, v, global: false) # replace only first occurence
  end


  defp replace_escape_sequences(token, _, _) do
    token
  end


  def join_segments(segments) do
    segments
    |> Stream.concat([""])
    |> Stream.map(&join_group(&1))
    |> Enum.join("'")
  end


  defp split_segments(tokenization = tokenization(tokens: tokens)) do
    tokens = tokens
    |> String.split(Regex.compile!(segment_end), trim: false)
    |> Enum.map(&split_groups/1)

    tokenization(tokenization, tokens: tokens)
  end


  defp join_group(group) do
    case group do
      [_|_] -> Stream.map(group, &join_elements(&1)) |> Enum.join("+")
      _     -> to_string(group)
    end
  end


  defp split_groups(raw) when is_binary(raw) do
    raw
    |> String.split(~r"(?<!\?)\+", trim: false)
    |> Enum.map(&split_elements/1)
  end


  defp join_elements(elements) do
    case elements do
      [_|_] -> Stream.map(elements, &join_elements(&1))|> Enum.join(":")
      _     -> to_string(elements)
    end
  end


  defp split_elements(raw) when is_binary(raw) do
    case String.split(raw, ~r"(?<!\?)\:", trim: false) do
      [head] -> unescape(head) |> replace_empty_by_nil
      list   -> list |> Enum.map(fn s -> s |> unescape |> replace_empty_by_nil end)
    end
  end


  def to_digit(string) when is_binary(string) do
    string |> String.to_integer
  end


  def to_number(string) when is_binary(string) do
    string |> String.to_integer
  end


  def to_id(string) when is_binary(string) do
    string
  end


  def to_amount(string) when is_binary(string) do
    string |> Amount.parse
  end


  def escape(raw) when is_binary(raw) do
    @control_chars
    |> Enum.reduce(
      raw,
      fn sign, acc ->
        String.replace(acc, sign |> Regex.escape |> Regex.compile!, "?#{sign}")
      end)
  end


  def unescape(raw) when is_binary(raw) do
    @control_chars
    |> Enum.reduce(
      raw,
      fn sign, acc ->
        String.replace(acc, "\\?#{Regex.escape(sign)}" |> Regex.compile!, sign)
      end)
  end


  defp replace_empty_by_nil("") do
    nil
  end


  defp replace_empty_by_nil(raw) when is_binary(raw) do
    raw
  end
end
