defmodule FinTex.Helper.Inspect do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      def inspect(%{segment: segment}, opts), do: segment |> Inspect.inspect(opts)
    end
  end
end
