defmodule FinTex.Error do
  @moduledoc false

  defexception [reason: nil]

  def message(exception) do
    "#{inspect exception.reason}"
  end
end
