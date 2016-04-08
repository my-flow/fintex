defmodule FinTex.Segment.HNSHK do
  @moduledoc false

  alias FinTex.Model.Dialog

  defstruct [segment: nil]

  use Timex

  def new(s, d = %Dialog{}) do

    %Dialog{
      bank:                bank,
      login:               login,
      country_code:        country_code,
      user_agent_name:     user_agent_name,
      client_system_id:    client_system_id,
      tan_scheme_sec_func: tan_scheme_sec_func,
      sec_ref:             sec_ref
    } = d

    v = case bank.version do
      "300" -> 4
      _     -> 3
    end

    now = DateTime.local
    date = [1, Timex.format!(now, "%Y%m%d", :strftime), Timex.format!(now, "%H%M%S", :strftime)]

    segment = [
      ["HNSHK", "?", v],
      ["PIN", 1],
      tan_scheme_sec_func,
      user_agent_name,
      1,
      1,
      [1, "", client_system_id],
      sec_ref,
      date,
      [1, 999, 1],
      [6, 10, 16],
      [country_code, bank.blz, login, "S", 0, 0]
    ]

    segment = case bank.version do
      "300" -> segment
      _     -> segment |> List.delete_at(1) # remove security profile
    end

    %__MODULE__{s | segment: segment}
  end
end


defimpl Inspect, for: FinTex.Segment.HNSHK do
  use FinTex.Helper.Inspect
end
