defmodule FinTex.Config.Identifier do
  @moduledoc false

  def country_code, do:       "280"

  def user_agent_name, do:    FinTex.Mixfile.project[:name]

  def user_agent_version, do: FinTex.Mixfile.project[:version]

end
