defmodule FinTex.User.FinChallengeResponder do
  @moduledoc """
    Provides a default implementation of the `FinTex.Model.ChallengeResponder` protocol.
  """

  alias FinTex.Model.Challenge
  alias FinTex.Tan.FlickerCode

  @type t :: term

  @doc false
  @spec read_user_input(Challenge.t) :: binary
  def read_user_input(challenge = %Challenge{title: title, label: label, medium: medium, data: data, format: format}) do
    IO.puts title
    IO.puts medium
    case format do
      :matrix -> data |> save_matrix(title)
      :hhd -> (data || label) |> FlickerCode.new |> FlickerCode.render |> IO.puts
      _ -> data |> IO.puts
    end
    do_read_user_input(challenge, nil)
  end

  defp do_read_user_input(_, response) when byte_size(response) == 6, do: response

  defp do_read_user_input(challenge = %Challenge{label: label}, _) do
    response = IO.gets("#{label}: ") |> String.strip
    do_read_user_input(challenge, response)
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


defimpl FinTex.Model.ChallengeResponder, for: FinTex.User.FinChallengeResponder do

  alias FinTex.User.FinChallengeResponder

  def read_user_input(challenge) do
    FinChallengeResponder.read_user_input(challenge)
  end
end
