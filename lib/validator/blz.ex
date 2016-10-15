defmodule FinTex.Validator.Blz do
  @moduledoc false

  alias Vex.Validators.Format
  use Vex.Validator

  @blz ~r/^\d{8}$/


  def validate(value, options) when is_list(options) do
    value
    |> Format.validate([with: @blz] |> Keyword.merge(options))
  end


  def validate(value, true), do: validate(value, [])
end
