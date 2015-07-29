defmodule FinTex.Segment.HKVVB do
  @moduledoc false

  alias FinTex.Model.Dialog

  defstruct []

  def create(
    _,
    %Dialog{
      :bank               => bank,
      :user_agent_name    => user_agent_name,
      :user_agent_version => user_agent_version
    }) do

    v = case bank.version do
      "300" -> 3
      _     -> 2
    end

    [
      ["HKVVB", "?", v],
      0,
      0,
      1,
      user_agent_name,
      user_agent_version
    ]

  end

end
