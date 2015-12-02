defmodule FinTex.Validator.Currency do
  @moduledoc false

  alias Vex.Validators.Format
  use Vex.Validator

  @currency ~r/^[A-Z]{3}$/


  def validate(value, options) when is_list(options) do
    value
    |> to_string
    |> Format.validate([with: @currency] |> Keyword.merge(options))
  end


  def validate(value, true), do: validate(value, [])

end
