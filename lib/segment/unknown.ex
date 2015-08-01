defmodule FinTex.Segment.Unknown do
  @moduledoc false

  defstruct [:segment]

  def new(segment) when is_list(segment) do
    %__MODULE__{segment: segment}
  end
end


defimpl Inspect, for: FinTex.Segment.Unknown do
  use FinTex.Helper.Inspect
end
