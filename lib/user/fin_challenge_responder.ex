defprotocol FinTex.User.FinChallengeResponder do

  alias FinTex.Model.Challenge

  @type t :: term

  @spec read_user_input(Challenge.t) :: binary
  def read_user_input(challenge)
end


defimpl FinTex.User.FinChallengeResponder, for: FinTex.Model.ChallengeResponder do

  alias FinTex.User.FinChallengeResponder

  def read_user_input(challenge) do
    FinChallengeResponder.read_user_input(challenge)
  end
end
