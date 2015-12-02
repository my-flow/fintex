defmodule FinTex.Validator.LatinCharSet do
  @moduledoc false

  alias Vex.Validators.Format
  use Vex.Validator

  @swift_latin_character_set ~r/^[a-zA-Z0-9\s.,\-\/+()':\?]*$/

  def validate(value, options) when is_list(options) do
    value
    |> to_string
    |> Format.validate([with: @swift_latin_character_set] |> Keyword.merge(options))
  end


  def validate(value, true), do: validate(value, [])

end
