defmodule FinTex.Model.ChallengeResponderTest do
  alias FinTex.Model.Challenge
  alias FinTex.Model.ChallengeResponder
  use ExUnit.Case
  import ExUnit.CaptureIO

  test "it should ask for the response of a matrix challenge" do
    data = [System.cwd!, "test", "fixtures", "challenge_HHD_UC.bin"]
    |> Path.join
    |> File.read!

    challenge = %Challenge{
      title: "title",
      label: "label",
      medium: "medium",
      format: :matrix,
      data: data
    }

    assert ~r/^title\nmedium$/m
    |> Regex.match?(capture_io([input: "123456", capture_prompt: false], fn ->
      challenge |> ChallengeResponder.read_user_input
    end))
  end


  test "it should ask for the response of a flicker challenge" do
    challenge = %Challenge{
      title: "title",
      label: "label",
      medium: "medium",
      format: :hhd,
      data: "039870110490631098765432100812345678041,00"
    }

    assert ~r/1784011049063F059876543210041234567844312C303019/m
    |> Regex.match?(capture_io([input: "123456", capture_prompt: false], fn ->
      challenge |> ChallengeResponder.read_user_input
    end))
  end
end
