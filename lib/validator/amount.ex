defmodule FinTex.Validator.Amount do
  @moduledoc false

  @min "0.01" |> Decimal.new
  @max "999999999.99" |> Decimal.new

  use Vex.Validator


  def validate(%Decimal{} = value, options) when is_list(options) do
    cond do
      value |> Decimal.nan? || value |> Decimal.inf?
        -> result(
            false,
            message(options, "must be a finite decimal number", value: value)
          )
      Decimal.compare(value, @min) == Decimal.new(-1)
        -> result(
            false,
            message(options, "must be greater than or equal to #{@min |> Decimal.to_string}", value: value)
          )
      Decimal.compare(@max, value) == Decimal.new(-1)
        -> result(
            false, message(options, "must be smaller than or equal to #{@max |> Decimal.to_string}", value: value)
          )
      true
        -> result(
            true,
            true
          )
    end
  end


  def validate(value, options) when is_list(options) and (is_binary(value) or is_integer(value) or is_float(value))  do
    value |> Decimal.new |> validate(options)
  end


  def validate(value, true), do: validate(value, [])


  defp result(true, _), do: :ok


  defp result(false, message), do: {:error, message}
end
