defmodule FinTex.Validator.Uri do
  @moduledoc false

  use Vex.Validator

  def validate(uri, _) when is_binary(uri) do
    case URI.parse(uri) do
      %URI{scheme: scheme} when scheme != "https"
        -> {:error, "scheme of URL \"#{uri}\" must be HTTPS."}
      %URI{host: nil}
        -> {:error, "host of URL \"#{uri}\" is invalid."}
      %URI{host: host}
        -> host |> to_char_list |> :inet.gethostbyname |> extract_message
    end
  end


  def validate(url, _) do
    {:error, "\"#{url}\" is not a valid URL"}
  end


  defp extract_message({:ok, _}) do
    :ok
  end


  defp extract_message(result = {:error, _}) do
    result
  end
end
