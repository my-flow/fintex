defmodule FinTex.User.ChallengeResponder do
  @moduledoc false

  alias FinTex.Model.Challenge

  def read_user_input(challenge = %Challenge{title: title, medium: medium, data: data}) do
    IO.puts title
    IO.puts medium
    data |> save_matrix(title)
    read_user_input(challenge, nil)
  end

  def read_user_input(_, response) when byte_size(response) == 6, do: response

  def read_user_input(challenge = %Challenge{label: label}, _) do
    response = IO.gets("#{label}: ") |> String.strip
    read_user_input(challenge, response)
  end

  defp save_matrix(nil, _), do: nil

  defp save_matrix(data, title) do
    <<l1, l2>> <> data = data
    length = (l1 + l2) * 8 # bytes
    <<mime_type :: size(length), _l1, _l2, data :: binary>> = data

    file = [System.tmp_dir!, title] |> Path.join
    file |> File.write!(data)
    IO.puts "Wrote challenge of type \"#{mime_type}\" to file #{file}"
  end

end
