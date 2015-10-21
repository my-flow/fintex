defmodule FinTex.Helper.Checksum do

  def luhn(input, base, mod), do: Luhn.checksum(input, base, mod)

  def xor(input) when is_binary(input) do
    use Bitwise
    import FinTex.Helper.Conversion

    input
    |> String.codepoints
    |> Stream.map(&String.to_integer(&1, 16))
    |> Enum.reduce(&bxor(&1, &2))
    |> to_hex(1)
  end
end
