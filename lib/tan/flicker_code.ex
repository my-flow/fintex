defmodule FinTex.Tan.FlickerCode do
  @moduledoc false

  # Flicker code extraction for optic chipTAN challenges.
  #
  # Based on Olaf Willuhn's Java implementation of flicker codes for HHD 1.3 and HHD 1.4,
  # available at https://github.com/willuhn/hbci4java/blob/master/src/org/kapott/hbci/manager/FlickerCode.java
  #
  # Based in parts on Lars-Dominik Braun's JavaScript implementation of HHD 1.3 flicker codes,
  # available at http://6xq.net/media/00/20/flickercode.html

  alias FinTex.Helper.Checksum
  alias FinTex.Helper.Conversion
  alias FinTex.Tan.StartCode
  alias FinTex.Tan.DataElement

  import Checksum
  import Conversion

  @lc_length_hhd14 3
  @lc_length_hhd13 2

  @type t :: %__MODULE__{
    lc: String.t,
    start_code: StartCode.t,
    data_elements: [DataElement.t]
  }

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
    c_len = String.length(c)

    case Integer.parse(lc) do
      :error -> :error
      {lc, _} when c_len == lc -> c |> do_parse(lc)
      _ -> code |> new(:hhd13)
    end
  end


  @spec render(t) :: String.t
  def render(module) do
    payload = create_payload(module)
    payload <> luhn(module) <> xor(payload)
  end


  defp do_parse(code, lc) do
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


  defp clean(code) when is_binary(code) do
    code = code
    |> String.replace(" ", "")
    |> String.strip

    case ~r/.*CHLGUC\d{4}(.*)CHLGTEXT.*/ |> Regex.run(code) do
      nil     -> code
      matches -> "0" <> (matches |> Enum.at(1))
    end
  end


  @spec create_payload(t) :: String.t
  defp create_payload(%{start_code: %{control_bytes: control_bytes} = start_code, data_elements: data_elements}) do
    payload = StartCode.render_length(start_code) <>
    (control_bytes |> Enum.map(&to_hex/1) |> Enum.join) <>
    StartCode.render_data(start_code)

    append = for data_element <- data_elements,
                 length <- [DataElement.render_length(data_element, start_code.version)],
                 data <- [DataElement.render_data(data_element)]
             do
              length <> data
    end
    append = append |> Enum.join

    payload = payload <> append
    lc = payload |> String.length |> Kernel.+(2) |> div(2) |> to_hex(2)
    lc <> payload
  end


  defp luhn(%{start_code: %{control_bytes: control_bytes} = start_code, data_elements: data_elements}) do
    luhnsum = [
      StartCode.render_data(start_code),
      control_bytes |> Enum.map(&to_hex/1),
      data_elements |> Enum.map(&DataElement.render_data/1)
    ]
    |> Enum.join
    |> String.reverse
    |> luhn(16, 10)

    10
    |> Kernel.-(luhnsum)
    |> rem(10)
    |> to_hex(1)
  end
end
