defmodule FinTex.Segment.Segment do
  @moduledoc false

  alias FinTex.Model.Dialog

  def max_version(d, name) do
    d
    |> all_versions(name)
    |> Enum.max
  end


  defp all_versions(%Dialog{:pintan => pintan}, full_module_name) do
    name = Regex.run(~r/\.([^\.]+)$/, full_module_name |> to_string, capture: :all_but_first)
    |> Enum.at(0)

    pintan
    |> Dict.get(name)
    |> Stream.map(fn [[_name, _no, v | _] | _] -> v end)
  end
end
