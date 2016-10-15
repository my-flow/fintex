defmodule FinTex.Helper.Command do
  @moduledoc false

  alias FinTex.Model.Dialog

  import Logger

  defmacro __using__(_) do
    quote do
      alias FinTex.Helper.Command
      alias FinTex.Model.Dialog
      import Command
      import Logger
    end
  end


  def validate!(valid_object) do
    if valid_object |> Vex.valid? do
      valid_object
    else
      raise FinTex.Error, reason: valid_object
      |> Vex.errors
      |> Enum.at(0)
      |> Tuple.to_list
      |> Enum.drop(1)
      |> Enum.join(" ")
    end
  end


  def create(module, d = %Dialog{}) do
    module.__struct__.new(module, d)
  end


  # Replace DKKAU by DIKAUS
  # Replace HKKAZ by KIKAZS
  # Replace HKPIN by HIPINS
  # Replace HKSPA by HISPAS
  def control_structure_to_bpd(name) when is_binary(name) do
    name |> String.upcase |> String.replace(~r/^(\w)\w(\w{3})$/, "\\1I\\2S")
  end


  # Replace DIKAUS by DKKAU
  # Replace KIKAZS by HKKAZ
  # Replace HIPINS by HKPIN
  # Replace HISPAS by HKSPA
  def bpd_to_control_structure(name) when is_binary(name) do
    name |> String.upcase |> String.replace(~r/^(\w)\w(\w{3}).+$/, "\\1K\\2")
  end


  def to_messages(feedback_segments) do
    feedback_segments
    |> Stream.flat_map(&Enum.at(&1, -1))
    |> Enum.sort(fn [code1 | _], [code2 | _] -> code1 >= code2 end)
  end


  def format_messages(feedback_segments) do
    feedback_segments
    |> to_messages
    |> Enum.map(fn
      [code, _ref, text] -> "#{code} #{text}"
      [code, _ref, text | params] -> "#{code} #{text} #{Enum.join(params, ", ")}"
    end)
  end


  def check_messages_for_errors(feedback_segments) do
    strings = feedback_segments |> format_messages
    strings |> Enum.each(&warn/1)

    case feedback_segments |> to_messages |> Enum.at(0) do
      [code | _] when code >= 9000 -> raise FinTex.Error, reason: strings |> Enum.join(" ")
      _ -> feedback_segments
    end
  end


  def dialog_id(response) do
    response[:HNHBK]
    |> Enum.at(0)
    |> Enum.at(3)
  end
end
