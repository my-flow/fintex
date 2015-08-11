defmodule FinTex.Validator.Uri do
  @moduledoc false

  use Vex.Validator

  def validate(value, options) when is_list(options) do
    case value |> to_string |> URI.parse do
      %URI{scheme: scheme} when scheme != "https"
        -> result(false, message(options, "must have HTTPS scheme", value: value))
      %URI{host: nil}
        -> result(false, message(options, "must have a valid host", value: value))
      %URI{host: host}
        -> host |> to_char_list |> :inet.gethostbyname |> extract_message(value, options)
    end
  end


  def validate(value, true), do: validate(value, [])


  defp result(true, _), do: :ok


  defp result(false, message), do: {:error, message}


  defp extract_message({:ok, message}, _, _), do: result(true, message)


  defp extract_message({:error, term}, value, options), do: result(false, message(options, to_string(term), value: value))
end
