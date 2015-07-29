defmodule FinTex.User.ChallengeResponderTest do
  alias FinTex.Model.Challenge
  alias FinTex.User.ChallengeResponder
  use ExUnit.Case
  import ExUnit.CaptureIO

  test "it should ask for the challenge" do
    data = [System.cwd!, "test", "fixtures", "challenge_HHD_UC.bin"]
    |> Path.join
    |> File.read!

    challenge = %Challenge{
      title: "title",
      label: "label",
      medium: "medium",
      data: data
    }

    assert ~r/^title\nmedium$/m
    |> Regex.match? capture_io([input: "123456", capture_prompt: false], fn ->
      challenge |> ChallengeResponder.read_user_input
    end)
  end
end
