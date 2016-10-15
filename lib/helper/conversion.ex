defmodule FinTex.Helper.Conversion do
  @moduledoc false

  def to_hex(s) when is_binary(s) do
    s
    |> String.to_charlist
    |> Stream.map(&to_hex(&1))
    |> Enum.join
  end


  def to_hex(n, len \\ 2) when is_integer(n) and is_integer(len) do
    n
    |> Integer.to_string(16)
    |> String.pad_leading(len, "0")
  end


  def to_bcd(s) do
    case s |> String.length |> rem(2) do
      0 -> s
      1 -> s <> "F"
    end
  end
end
