defmodule FinTex.Config.Identifier do
  @moduledoc false

  alias FinTex.Mixfile

  def country_code, do:       "280"

  def user_agent_name, do:    Mixfile.project[:name]

  def user_agent_version, do: Mixfile.project[:version]

end
