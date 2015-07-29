defmodule FinTex.Segment.HNVSK do
  @moduledoc false

  alias FinTex.Model.Dialog
  alias FinTex.Parser.Lexer

  use Timex

  defstruct []

  def create(_, d = %Dialog{}) do

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

    now = Date.local
    date = [1, DateFormat.format!(now, "%Y%m%d", :strftime), DateFormat.format!(now, "%H%M%S", :strftime)]

    result = [
      ["HNVSK", 998, v],
      998,
      1,
      [1, "", Lexer.escape(client_system_id)],
      date,
      [2, 2, 13, Lexer.encode_binary(<<0, 0, 0, 0, 0, 0, 0, 0>>), 5, 1],
      ["#{country_code}:#{bank.blz}", login, "V", 0, 0],
      0
    ]

    case bank.version do
      "300" -> result |> List.insert_at(1, ["PIN", 1]) # add security profile
      _     -> result
    end
  end
end
