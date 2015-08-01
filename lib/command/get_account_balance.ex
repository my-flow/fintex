defmodule FinTex.Command.GetAccountBalance do
  @moduledoc false

  alias FinTex.Command.AbstractCommand
  alias FinTex.Command.Sequencer
  alias FinTex.Model.Account
  alias FinTex.Model.Balance
  alias FinTex.Segment.HNHBK
  alias FinTex.Segment.HNSHK
  alias FinTex.Segment.HKSAL
  alias FinTex.Segment.HNSHA
  alias FinTex.Segment.HNHBS

  use AbstractCommand
  use Timex

  def get_account_balance(seq, account = %Account{}) do

    request_segments = [
      %HNHBK{},
      %HNSHK{},
      %HKSAL{account: account},
      %HNSHA{},
      %HNHBS{}
    ]

    {:ok, response} = seq |> Sequencer.call_http(request_segments)

    info = response[:HISAL] |> Enum.at(0)

	  %Account{account |
	    :balance => %Balance{
        :balance      => info |> Enum.at(4) |> Enum.at(1)
                          |> (&(if info |> Enum.at(4) |> Enum.at(0) == "C",
                                do: &1,
                              else:
                                "-#{&1}")
                          ).(),
	      :balance_date => to_date(
                          info |> Enum.at(4) |> Enum.at(3),
                          info |> Enum.at(4) |> Enum.at(4)
                         ),
        :credit_line  => info |> Enum.at(6, []) |> Enum.at(0)
	    }
	  }
  end


  defp to_date(date, nil) when is_binary(date) and byte_size(date) == 8 do
    to_date(date, "000000")
  end


  defp to_date(date, time)
  when is_binary(date) and is_binary(time) and byte_size(date) == 8 and byte_size(time) == 6 do
    date = Regex.run(~r"(\d{4})(\d{2})(\d{2})", date, capture: :all_but_first)
    time = Regex.run(~r"(\d{2})(\d{2})(\d{2})", time, capture: :all_but_first)

    Date.from(
      {
        {Enum.at(date, 0), Enum.at(date, 1), Enum.at(date, 2)},
        {Enum.at(time, 0), Enum.at(time, 1), Enum.at(time, 2)},
      },
      Date.timezone("GMT")
    )
  end
end
