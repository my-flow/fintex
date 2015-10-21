defmodule FinTex.Tan.FlickerCode do
  @moduledoc false

  alias FinTex.Helper.Checksum
  alias FinTex.Helper.Conversion
  alias FinTex.Tan.StartCode
  alias FinTex.Tan.DataElement

  @lc_length_hhd14 3
  @lc_length_hhd13 2

  import Checksum
  import Conversion

  defstruct [
    :lc,
    :start_code,
    :data_elements
  ]


  def new(code, version \\ :hhd14) when is_binary(code) and is_atom(version) do
    c = code |> clean

    len = case version do
      :hhd14 -> @lc_length_hhd14
      :hhd13 -> @lc_length_hhd13
    end

    {lc, c} = c |> String.split_at(len)
    {lc, _} = Integer.parse(lc)

    case String.length(c) == lc do
      true  -> c |> parse(lc)
      false -> code |> new(:hhd13)
    end
  end


  def parse(code, lc) do
    {start_code, code} = StartCode.new(code)
    {data_element1, code} = DataElement.new(code)
    {data_element2, code} = DataElement.new(code)
    {data_element3, _} = DataElement.new(code)

    %__MODULE__{
      lc: lc,
      start_code: start_code,
      data_elements: [data_element1, data_element2, data_element3]
    }
  end


  def render(m) do
    payload = create_payload(m)
    payload <> luhn(m) <> xor(payload)
  end


  defp clean(code) when is_binary(code) do
    code = code
    |> String.replace(" ", "")
    |> String.strip

    case ~r/.*CHLGUC\d{4}(.*)CHLGTEXT.*/ |> Regex.run(code) do
      nil     -> code
      matches -> "0" <> (matches |> Enum.at(1))
    end
  end


  defp create_payload(%__MODULE__{start_code: start_code, data_elements: data_elements}) do
    payload = StartCode.render_length(start_code) <>
    (start_code.control_bytes |> Enum.map(&to_hex/1) |> Enum.join) <>
    StartCode.render_data(start_code)

    append = for data_element <- data_elements,
                 length = DataElement.render_length(data_element, start_code.version),
                 data = DataElement.render_data(data_element)
             do
              length <> data
    end |> Enum.join

    payload = payload <> append
    lc = (String.length(payload) + 2) |> div(2) |> to_hex(2)
    lc <> payload
  end


  defp luhn(%__MODULE__{start_code: start_code, data_elements: data_elements}) do
    luhnsum = (StartCode.render_data(start_code) <>
    (start_code.control_bytes |> Enum.map(&to_hex/1) |> Enum.join) <>
    (data_elements |> Enum.map(&DataElement.render_data/1) |> Enum.join))
    |> String.reverse
    |> luhn(16, 10)

    10 - luhnsum |> rem(10) |> to_hex(1)
  end
end
