defmodule FinTex.Tan.StartCode do
  @moduledoc false

  alias FinTex.Helper.Conversion
  alias FinTex.Tan.DataElement

  import Conversion

  defdelegate render_data(m), to: DataElement
  defdelegate bitsum(n, bits), to: DataElement

  @bit_controlbyte 7

  @type t :: %__MODULE__{
    version: :hhd13 | :hhd14,
    length: non_neg_integer,
    lde: non_neg_integer,
    control_bytes: [non_neg_integer],
    data: String.t
  }

  defstruct [
    :version,
    :length,
    :lde,
    :control_bytes,
    :data
  ]

  def new(code) when is_binary(code) do
    {lde, code} = code |> String.split_at(2)
    {lde, _} = lde |> Integer.parse(16)
    len = lde |> bitsum(5)
    {{control_bytes, code}, version} = if lde |> bit?(@bit_controlbyte) do
      {parse_control_bytes(code), :hhd14}
    else
      {{[], code}, :hhd13}
    end

    {data, code} = code |> String.split_at(len)
    m = %__MODULE__{
      version: version,
      length: len,
      lde: lde,
      control_bytes: control_bytes,
      data: data
    }
    {m, code}
  end


  def render_length(m = %{version: version, control_bytes: control_bytes}) do
    s = DataElement.render_length(m, version)
    if version == :hhd13 || control_bytes |> Enum.empty? do
      s
    else
      reincode(m, s)
    end
  end


  defp reincode(%{control_bytes: control_bytes}, s) do
    use Bitwise
    {len, _} = s |> Integer.parse(16)
    len = if control_bytes |> Enum.count > 0 do
      len + (1 <<< @bit_controlbyte)
    else
      len
    end
    len |> to_hex(2)
  end


  defp bit?(n, bit) when is_integer(n) and is_integer(bit) do
    use Bitwise
    n |> band(1 <<< bit) != 0
  end


  defp parse_control_bytes(bytes \\ [], code, counter \\ 0)

  defp parse_control_bytes(bytes, code, 9) do
    {bytes, code}
  end

  defp parse_control_bytes(bytes, code, counter) do
    {control_byte, code} = code |> String.split_at(2)
    {control_byte, _} = control_byte |> Integer.parse(16)

    bytes = bytes ++ [control_byte]

    if control_byte |> bit?(@bit_controlbyte) do
      parse_control_bytes(bytes, code, counter + 1)
    else
      {bytes, code}
    end
  end
end
