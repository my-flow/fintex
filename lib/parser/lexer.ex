defmodule FinTex.Parser.Lexer do
  @moduledoc false

  @control_chars ["?", "+", ":", "'", "@"]


  @spec segment_end :: String.t
  def segment_end, do: "(?<!\\?)'"

  @spec escaped_binary(String.t) :: Regex.t
  def escaped_binary(len), do: Regex.compile!("\\A(.*)@#{len}@(.{#{len}})(.*)\\z", "mUs")

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


  @doc """
  Convert charset from UTF-8 to ISO 8859-1
  """
  @spec latin1_to_utf8(String.t) :: String.t
  def latin1_to_utf8(data) when is_binary(data) do
    data |> :unicode.characters_to_binary(:latin1, :utf8)
  end


  @spec join_segments(Enumerable.t) :: String.t
  def join_segments(segments) do
    segments
    |> Stream.concat([""])
    |> Stream.map(&join_group(&1))
    |> Enum.join("'")
  end


  @spec split_segments(String.t) :: [String.t]
  def split_segments(raw) do
    raw
    |> String.split(Regex.compile!(segment_end), trim: false)
    |> Enum.map(&split_groups/1)
  end


  @spec join_group(list | any) :: String.t
  defp join_group(group) when is_list(group) do
    group
    |> Stream.map(&join_elements(&1))
    |> Enum.join("+")
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
    elements
    |> Stream.map(&join_elements(&1))
    |> Enum.join(":")
  end

  defp join_elements(elements) do
    to_string(elements)
  end


  @spec split_elements(String.t) :: String.t | nil
  defp split_elements(raw) when is_binary(raw) do
    case String.split(raw, ~r"(?<!\?)\:", trim: false) do
      [head] -> head |> unescape |> replace_empty_by_nil
      list   -> list |> Enum.map(fn s -> s |> unescape |> replace_empty_by_nil end)
    end
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
  defp unescape(raw) when is_binary(raw) do
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
