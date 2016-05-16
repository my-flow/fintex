defmodule FinTex.Parser.Lexer do
  @moduledoc false

  alias FinTex.Helper.Amount
  require Record

  @type t :: record(:tokenization, tokens: [String.t] | String.t, escape_sequences: map)
  Record.defrecordp :tokenization,
    tokens: nil,
    escape_sequences: nil

  @control_chars ["?", "+", ":", "'", "@"]


  @spec segment_end :: String.t
  def segment_end, do: "(?<!\\?)'"

  @spec escaped_binary(String.t) :: Regex.t
  def escaped_binary(length), do: Regex.compile!("\\A(.*)@#{length}@(.{#{length}})(.*)\\z", "mUs")

  @spec escaped_binary :: Regex.t
  def escaped_binary, do: Regex.compile!("\\A(.*)@\\d+@.*\\z", "mUs")


  @spec encode_binary(String.t) :: String.t
  def encode_binary(raw) when is_binary(raw) do
    "@#{inspect byte_size(raw)}@#{raw}"
  end


  @spec escaped_binary?(String.t) :: boolean
  def escaped_binary?(raw) do
    escaped_binary |> Regex.match?(raw)
  end


  @spec remove_newline(String.t) :: String.t
  def remove_newline(string) when is_binary(string) do
    ~r(\R) |> Regex.replace(string, "")
  end


  @spec split(String.t) :: [String.t]
  def split(raw) when is_binary(raw) do
    raw
    |> extract_binaries(Map.new)
    |> latin1_to_utf8
    |> split_segments
    |> replace_escape_sequences
  end


  @spec extract_binaries(String.t, map) :: t
  defp extract_binaries(raw, map) do
    case Regex.run(~r/@(\d+)@.*/Us, raw, capture: :all_but_first) do
      [length] when is_binary(length) ->
        ref_counter = round(:random.uniform * 100_000_000)
        marker = "--#{inspect ref_counter}--"

        [_, binary_data, _] = length
        |> escaped_binary
        |> Regex.run(raw, capture: :all_but_first)

        raw = length
        |> escaped_binary
        |> Regex.replace(raw, "\\1#{marker}\\3", global: false) # replace only first occurence

        map = map |> Map.put(marker, binary_data)
        extract_binaries(raw, map)
      _ ->
        tokenization(tokens: raw, escape_sequences: map)
    end
  end


  @spec latin1_to_utf8(t) :: t
  def latin1_to_utf8(tokenization = tokenization(tokens: tokens)) do
    tokenization(tokenization, tokens: latin1_to_utf8(tokens))
  end


  @spec latin1_to_utf8(String.t) :: String.t
  def latin1_to_utf8(string) do
    string
    |> :unicode.characters_to_binary(:latin1, :utf8)
  end


  @doc """
  Convert charset from UTF-8 to ISO 8859-1
  """
  @spec utf8_to_latin1(String.t) :: String.t
  def utf8_to_latin1(string) when is_binary(string) do
    string
    |> :unicode.characters_to_binary(:utf8, :latin1)
  end


  @spec replace_escape_sequences(t) :: term
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

  defp replace_escape_sequences(token, _, _) do
    token
  end


  @spec join_segments(Enumerable.t) :: String.t
  def join_segments(segments) do
    segments
    |> Stream.concat([""])
    |> Stream.map(&join_group(&1))
    |> Enum.join("'")
  end


  @spec split_segments(t) :: t
  defp split_segments(tokenization = tokenization(tokens: tokens)) do
    tokens = tokens
    |> String.split(Regex.compile!(segment_end), trim: false)
    |> Enum.map(&split_groups/1)

    tokenization(tokenization, tokens: tokens)
  end


  @spec join_group(list | any) :: String.t
  defp join_group(group) when is_list(group) do
    Stream.map(group, &join_elements(&1)) |> Enum.join("+")
  end

  defp join_group(group) do
    to_string(group)
  end


  @spec split_groups(String.t) :: [String.t]
  defp split_groups(raw) when is_binary(raw) do
    raw
    |> String.split(~r"(?<!\?)\+", trim: false)
    |> Enum.map(&split_elements/1)
  end


  @spec join_elements(list | any) :: String.t
  defp join_elements(elements) when is_list(elements) do
    Stream.map(elements, &join_elements(&1))|> Enum.join(":")
  end

  defp join_elements(elements) do
    to_string(elements)
  end


  @spec split_elements(String.t) :: String.t | nil
  defp split_elements(raw) when is_binary(raw) do
    case String.split(raw, ~r"(?<!\?)\:", trim: false) do
      [head] -> unescape(head) |> replace_empty_by_nil
      list   -> list |> Enum.map(fn s -> s |> unescape |> replace_empty_by_nil end)
    end
  end


  @spec to_digit(String.t) :: integer
  def to_digit(string) when is_binary(string) do
    string |> String.to_integer
  end


  @spec to_number(String.t) :: integer
  def to_number(string) when is_binary(string) do
    string |> String.to_integer
  end


  @spec to_id(String.t) :: String.t
  def to_id(string) when is_binary(string) do
    string
  end


  @spec to_amount(String.t) :: Decimal.t
  def to_amount(string) when is_binary(string) do
    string |> Amount.parse
  end


  @spec escape(String.t) :: String.t
  def escape(raw) when is_binary(raw) do
    @control_chars
    |> Enum.reduce(
      raw,
      fn sign, acc ->
        String.replace(acc, sign |> Regex.escape |> Regex.compile!, "?#{sign}")
      end)
  end


  @spec unescape(String.t) :: String.t
  def unescape(raw) when is_binary(raw) do
    @control_chars
    |> Enum.reduce(
      raw,
      fn sign, acc ->
        String.replace(acc, "\\?#{Regex.escape(sign)}" |> Regex.compile!, sign)
      end)
  end


  @spec replace_empty_by_nil(String.t) :: String.t | nil
  defp replace_empty_by_nil("") do
    nil
  end


  defp replace_empty_by_nil(raw) when is_binary(raw) do
    raw
  end
end
