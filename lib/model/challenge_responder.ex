defprotocol FinTex.Model.ChallengeResponder do

  alias FinTex.Model.Challenge

  @type t :: term

  @spec read_user_input(Challenge.t) :: binary
  def read_user_input(challenge)

end
