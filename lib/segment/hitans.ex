defmodule FinTex.Segment.HITANS do
  @moduledoc false

  alias FinTex.User.FinTANScheme

  defstruct [segment: nil]

  def new(segment) when is_list(segment) do
    [[_, _, v | _] | _] = segment

    {offset, params_count} = case v do
      1 -> {4, 11}
      2 -> {3, 15}
      3 -> {3, 18}
      4 -> {3, 22}
      5 -> {3, 22}
    end

    %__MODULE__{
      segment:
        [
          segment |> Enum.at(0),
          segment |> Enum.at(1),
          segment |> Enum.at(2),
          segment |> Enum.at(3),
          (segment |> Enum.at(4) |> Enum.take(offset)) ++
          [segment |> Enum.at(4) |> Enum.drop(offset) |> Enum.chunk(params_count)]
        ]
    }
  end


  def to_tan_schemes(segment = [["HITANS", _, v = 1 | _] | _]) do
    segment
    |> Enum.at(4)
    |> Enum.at(4)
    |> Enum.map(fn method_params ->
        %FinTANScheme{
          sec_func: method_params |> Enum.at(0),
          format:   method_params |> Enum.at(2) |> to_format,
          name:     method_params |> Enum.at(3),
          label:    method_params |> Enum.at(6),
          v:        v
        }
      end)
  end


  def to_tan_schemes(segment = [["HITANS", _, v = 2 | _] | _]) do
    segment
    |> Enum.at(4)
    |> Enum.at(3)
    |> Enum.map(fn method_params ->
        %FinTANScheme{
          sec_func: method_params |> Enum.at(0),
          format:   nil |> to_format,
          name:     method_params |> Enum.at(3),
          label:    method_params |> Enum.at(6),
          v:        v
        }
      end)
  end


  def to_tan_schemes(segment = [["HITANS", _, v = 3 | _] | _]) do
    segment
    |> Enum.at(4)
    |> Enum.at(3)
    |> Enum.map(fn method_params ->
        %FinTANScheme{
          sec_func: method_params |> Enum.at(0),
          format:   method_params |> Enum.at(2) |> to_format,
          name:     method_params |> Enum.at(3),
          label:    method_params |> Enum.at(6),
          medium_name_required: case method_params |> Enum.at(16) do
            "0" -> false
            "1" -> false
            "2" -> true
          end,
          v:        v
        }
      end)
  end


  def to_tan_schemes(segment = [["HITANS", _, v = 4 | _] | _]) do
    segment
    |> Enum.at(4)
    |> Enum.at(3)
    |> Enum.map(fn method_params ->
        %FinTANScheme{
          sec_func: method_params |> Enum.at(0),
          format:   method_params |> Enum.at(3) |> to_format,
          name:     method_params |> Enum.at(5),
          label:    method_params |> Enum.at(8),
          medium_name_required: case method_params |> Enum.at(20) do
            "0" -> false
            "1" -> false
            "2" -> true
          end,
          v:        v
        }
      end)
  end


  def to_tan_schemes(segment = [["HITANS", _, v = 5 | _] | _]) do
    segment
    |> Enum.at(4)
    |> Enum.at(3)
    |> Enum.map(fn method_params ->
        %FinTANScheme{
          sec_func: method_params |> Enum.at(0),
          format:   method_params |> Enum.at(2) |> to_format,
          name:     method_params |> Enum.at(5),
          label:    method_params |> Enum.at(8),
          medium_name_required: case method_params |> Enum.at(20) do
            "0" -> false
            "1" -> false
            "2" -> true
          end,
          v:        v
        }
      end)
  end


  defp to_format("HHD" <> _), do: :hhd
  defp to_format("SM@RTTAN" <> _), do: :hhd
  defp to_format("MS" <> _), do: :matrix
  defp to_format("MC" <> _), do: :matrix
  defp to_format(nil), do: :text
  defp to_format(_), do: :text
end


defimpl Inspect, for: FinTex.Segment.HITANS do
  use FinTex.Helper.Inspect
end
