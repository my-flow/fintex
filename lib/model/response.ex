defmodule FinTex.Model.Response do
  @moduledoc false

  defstruct [
    :index_by_segment_names,
    :index_by_reference
  ]

  def new(segments) do
    index_by_segment_names = segments
    |> Enum.group_by(fn s -> s |> Enum.at(0, []) |> Enum.at(0) end)
    |> Stream.map(fn {k, v} -> {k, v |> Enum.sort(&sort_segments/2)} end)
    |> Enum.into(HashDict.new)

    index_by_reference = segments
    |> Stream.filter(fn s -> s |> Enum.at(0, []) |> Enum.count == 4 end)
    |> Enum.group_by(fn s -> s |> Enum.at(0, []) |> Enum.at(3) end)
    |> Enum.into(HashDict.new)

    %__MODULE__{
      index_by_segment_names: index_by_segment_names,
      index_by_reference: index_by_reference
    }
  end


  def sort_segments [[_, pos1 | _] | _], [[_, pos2 | _] | _] do
    pos1 <= pos2
  end
end


defimpl Access, for: FinTex.Model.Response do

  def get(%{index_by_segment_names: index_by_segment_names}, key) when is_atom(key) do
    index_by_segment_names |> Access.get(key |> to_string) || []
  end

  def get(%{index_by_reference: index_by_reference}, ref) when is_integer(ref) and ref >= 0 do
    index_by_reference |> Access.get(ref ) || []
  end

  def get(_dict, key) do
    raise ArgumentError,
      "the access protocol for FinTex.Model.Response expect the key to be an atom, got: #{inspect key}"
  end

  def get_and_update(response, _, _) do
   raise Protocol.UndefinedError,
      protocol: @protocol,
      value: response,
      description: "updating is not supported"
  end
end


defimpl Inspect, for: FinTex.Model.Response do
  def inspect(%{index_by_segment_names: index_by_segment_names}, opts) do
    index_by_segment_names
    |> Dict.values
    |> Stream.concat
    |> Enum.sort(&FinTex.Model.Response.sort_segments/2)
    |> Inspect.inspect(opts)
  end
end


defimpl String.Chars, for: FinTex.Model.Response do
  def to_string(response), do: response |> inspect(pretty: true, limit: :infinity)
end
