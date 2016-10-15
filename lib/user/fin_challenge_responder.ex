defprotocol FinTex.User.FinChallengeResponder do

  alias FinTex.Model.Challenge

  @type t :: term

  @spec read_user_input(Challenge.t) :: binary
  def read_user_input(challenge)
end


defimpl FinTex.User.FinChallengeResponder, for: FinTex.Model.ChallengeResponder do

  alias FinTex.Model.ChallengeResponder

  def read_user_input(challenge) do
    ChallengeResponder.read_user_input(challenge)
  end
end
