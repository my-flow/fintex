defmodule FinTex.Validator.Bic do
  @moduledoc false

  use Vex.Validator

  def validate(value, options) when is_list(options) do
    if value |> Bankster.bic_valid? do
      :ok
    else
      {:error, message(options, "must be valid", value: value)}
    end
  end


  def validate(value, true), do: validate(value, [])
end
