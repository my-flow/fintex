defmodule FinTex.Validator.Iban do
  @moduledoc false

  use Vex.Validator

  def validate(value, options) when is_list(options) do
    case value |> Bankster.iban_validate do
      {:error, message}
        -> {:error, message(options, message |> to_string, value: value)}
      {:ok, _}
        -> :ok
    end
  end


  def validate(value, true), do: validate(value, [])
end
