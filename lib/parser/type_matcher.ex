defmodule FinTex.Parser.TypeMatcher do
  @moduledoc false

  defmacro handle(segment, function, version \\ nil) do
    quote do
      [[name | _] | _] = unquote(segment)

      module = Module.concat [Elixir, FinTex, Segment, String.upcase name]

      case Code.ensure_loaded?(module) && function_exported?(module, unquote(function), 2) do
        true  ->
          apply(module, unquote(function), [unquote(segment), unquote(version)])

        false ->
          case function_exported?(module, unquote(function), 1) do
            true  -> apply(module, unquote(function), [unquote(segment)])
            false -> unquote(segment)
          end
      end
    end
  end
end
