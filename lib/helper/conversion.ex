defmodule FinTex.Helper.Conversion do
  @moduledoc false

  alias FinTex.Helper.Amount

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


  @spec to_hex(String.t) :: String.t
  def to_hex(s) when is_binary(s) do
    s
    |> String.to_charlist
    |> Stream.map(&to_hex(&1))
    |> Enum.join
  end


  @spec to_hex(integer, non_neg_integer) :: String.t
  def to_hex(n, len \\ 2) when is_integer(n) and is_integer(len) do
    n
    |> Integer.to_string(16)
    |> String.pad_leading(len, "0")
  end


  @spec to_bcd(String.t) :: String.t
  def to_bcd(s) when is_binary(s) do
    case s |> String.length |> rem(2) do
      0 -> s
      1 -> s <> "F"
    end
  end
end
