defmodule FinTex.Segment.HNSHA do
  @moduledoc false

  alias FinTex.Model.Dialog

  defstruct [:response]

  def create(
    %__MODULE__{response: response},
    %Dialog{
      bank: bank,
      user_agent_name: user_agent_name,
      pin: pin
    }
    ) do

    v = case bank.version do
      "300" -> 2
      _     -> 1
    end

    pin = case response do
      nil -> pin
      _   -> [pin, response]
    end

    [
    	["HNSHA", "?", v],
    	user_agent_name,
    	"",
    	pin
    ]
  end

end
