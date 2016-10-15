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
    IO.puts handle_format(format, data, label, title)
    do_read_user_input(challenge, nil)
  end


  defp handle_format(:hhd, data, label, _title) do
    payload = data || label
    case payload |> FlickerCode.new do
      :error -> data
      f -> f |> FlickerCode.render
    end
  end


  defp handle_format(:matrix, nil, _label, _title) do
    ""
  end


  defp handle_format(:matrix, data, _label, title) do
    <<l1, l2>> <> data = data
    len = (l1 + l2) * 8 # bytes
    <<_mime_type :: size(len), _l1, _l2, data :: binary>> = data

    file = [System.tmp_dir!, title] |> Path.join
    file |> File.write!(data)
    "Wrote challenge to file #{file}"
  end


  defp handle_format(_format, data, _label, _title) do
    data
  end


  defp do_read_user_input(_, response) when byte_size(response) == 6, do: response

  defp do_read_user_input(challenge = %Challenge{label: label}, _) do
    response = "#{label}: "
    |> IO.gets
    |> String.trim
    do_read_user_input(challenge, response)
  end
end


defimpl FinTex.Model.ChallengeResponder, for: FinTex.User.FinChallengeResponder do

  alias FinTex.User.FinChallengeResponder

  def read_user_input(challenge) do
    FinChallengeResponder.read_user_input(challenge)
  end
end
