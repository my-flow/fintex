defmodule FinTex.Model.Response do
  @moduledoc false

  defstruct [
    :index_by_segment_names,
    :index_by_reference
  ]

  def new(segments) do
    index_by_segment_names = segments
    |> Enum.group_by(fn s -> s.segment |> Enum.at(0, []) |> Enum.at(0) end)
    |> Stream.map(fn {k, v} -> {k, v |> Enum.sort(&sort_segments/2)} end)
    |> Enum.into(HashDict.new)

    index_by_reference = segments
    |> Stream.filter(fn s -> s.segment |> Enum.at(0, []) |> Enum.count == 4 end)
    |> Enum.group_by(fn s -> s.segment |> Enum.at(0, []) |> Enum.at(3) end)
    |> Enum.into(HashDict.new)

    %__MODULE__{
      index_by_segment_names: index_by_segment_names,
      index_by_reference: index_by_reference
    }
  end


  def sort_segments %{segment: [[_, pos1 | _] | _]}, %{segment: [[_, pos2 | _] | _]} do
    pos1 <= pos2
  end


  def fetch(container, key) when is_atom(key) do
    {:ok, container |> get(key, [])}
  end

  def fetch(container, ref) when is_integer(ref) and ref >= 0 do
    {:ok, container |> get(ref, [])}
  end

  def fetch(_dict, _key) do
    :error
  end


  def get(container, key, default \\ nil)

  def get(%{index_by_segment_names: index_by_segment_names}, key, default) when is_atom(key) do
    value = index_by_segment_names |> Access.get(key |> Atom.to_string) || default
    case value do
      [_|_] -> value |> Stream.map(fn s -> s.segment end)
      _ -> value
    end
  end

  def get(%{index_by_reference: index_by_reference}, ref, default) when is_integer(ref) and ref >= 0 do
    value = index_by_reference |> Access.get(ref) || default
    case value do
      [_|_] -> value |> Stream.map(fn s -> s.segment end)
      _ -> value
    end
  end

  def get(_dict, _key, _default) do
    :error
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
