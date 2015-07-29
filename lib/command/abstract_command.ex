defmodule FinTex.Command.AbstractCommand do
  @moduledoc false

  alias FinTex.Model.Dialog

  defmacro __using__(_) do
    quote do
      alias FinTex.Model.Dialog
      alias FinTex.Command.AbstractCommand
      import AbstractCommand
      import Logger
    end
  end


  def create(struct, d = %Dialog{}) do
    struct.__struct__.create(struct, d)
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


  def messages(feedback_segments) do
    feedback_segments
    |> Stream.map(&Enum.at(&1, -1))
    |> Stream.concat
    |> Enum.sort(fn [code1 | _], [code2 | _] -> code1 >= code2 end)
  end


  def dialog_id(response) do
    response[:HNHBK]
    |> Enum.at(0)
    |> Enum.at(3)
  end
end
