defmodule FinTex.Tan.DataElement do
  @moduledoc false

  alias FinTex.Helper.Conversion

  import Conversion

  @bit_encoding 6

  @type t :: %__MODULE__{
    length: Integer.t,
    lde: Integer.t,
    data: String.t
  }

  defstruct [
    :length,
    :lde,
    :data
  ]


  def new(code) when is_binary(code) do
    case code do
      ""  -> {%__MODULE__{}, code}
      _   -> do_new(code)
    end
  end


  defp do_new(code) when is_binary(code) do
    {lde, code} = code |> String.split_at(2)
    {lde, _} = lde |> Integer.parse
    len = lde
    {data, code} = code |> String.split_at(len)
    m = %__MODULE__{
      length: len,
      lde: lde,
      data: data
    }
    {m, code}
  end


  def render_length(%{data: nil}, _), do: ""

  def render_length(m, version) do
    use Bitwise
    len = m |> render_data |> String.length |> div(2)

    cond do
      encoding(m) == :bcd -> to_hex(len)
      version == :hhd14   -> to_hex(len + (1 <<< @bit_encoding), 2)
      true                -> "1" <> to_hex(len, 1)
    end
  end


  def encoding(%{data: nil}), do: :bcd

  def encoding(%{data: data}) do
    if data |> String.match?(~r/^[0-9]{1,}$/u) do
      :bcd
    else
      :ascii
    end
  end


  def render_data(%{data: nil}), do: ""

  def render_data(m = %{data: data}) do
    case encoding(m) do
      :ascii -> data |> to_hex
      :bcd   -> data |> to_bcd
    end
  end


  def bitsum(n, bits) when is_integer(n) and is_integer(bits) do
    use Bitwise
    n |> band((2 |> :math.pow(bits + 1) |> round) - 1)
  end
end
