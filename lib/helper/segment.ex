defmodule FinTex.Helper.Segment do
  @moduledoc false

  alias FinTex.Model.Dialog


  @spec max_version(Dialog.t, atom) :: integer
  def max_version(d, name) do
    d
    |> all_versions(name)
    |> Enum.max
  end


  @spec all_versions(Dialog.t, atom) :: integer
  defp all_versions(%Dialog{pintan: pintan}, full_module_name) do
    name = ~r/\.([^\.]+)$/
    |> Regex.run(full_module_name |> to_string, capture: :all_but_first)
    |> Enum.at(0)

    pintan
    |> Map.get(name)
    |> Stream.map(fn [[_name, _no, v | _] | _] -> v end)
  end
end
