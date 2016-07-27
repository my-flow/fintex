defmodule FinTex.Segment.HNVSK do
  @moduledoc false

  alias FinTex.Model.Dialog
  alias FinTex.Parser.Lexer

  use Timex

  defstruct [segment: nil]

  def new(s, d = %Dialog{}) do

    %Dialog{
      bank:             bank,
      login:            login,
      country_code:     country_code,
      client_system_id: client_system_id
    } = d

    v = case bank.version do
      "300" -> 3
      _     -> 2
    end

    now = Timex.local
    date = [1, Timex.format!(now, "%Y%m%d", :strftime), Timex.format!(now, "%H%M%S", :strftime)]

    segment = [
      ["HNVSK", 998, v],
      998,
      1,
      [1, "", Lexer.escape(client_system_id)],
      date,
      [2, 2, 13, Lexer.encode_binary(<<0, 0, 0, 0, 0, 0, 0, 0>>), 5, 1],
      ["#{country_code}:#{bank.blz}", login, "V", 0, 0],
      0
    ]

    segment = case bank.version do
      "300" -> segment |> List.insert_at(1, ["PIN", 1]) # add security profile
      _     -> segment
    end

    %__MODULE__{s | segment: segment}
  end
end


defimpl Inspect, for: FinTex.Segment.HNVSK do
  use FinTex.Helper.Inspect
end
