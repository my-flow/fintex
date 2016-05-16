defmodule FinTex.Segment.HNSHA do
  @moduledoc false

  alias FinTex.Model.Dialog

  defstruct [:response, segment: nil]

  def new(
    s = %__MODULE__{response: response},
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

    %__MODULE__{s |
      segment:
        [
        	["HNSHA", "?", v],
        	user_agent_name,
        	"",
        	pin
        ]
    }
  end
end


defimpl Inspect, for: FinTex.Segment.HNSHA do

  @asterisks "******"

  def inspect(%{segment: segment}, opts) do
    segment
    |> Enum.to_list
    |> List.replace_at(3, @asterisks)
    |> Inspect.inspect(opts)
  end
end
