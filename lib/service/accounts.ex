defmodule FinTex.Service.Accounts do
  @moduledoc false

  alias FinTex.Command.AbstractCommand
  alias FinTex.Command.Sequencer
  alias FinTex.Model.Account
  alias FinTex.Model.TANScheme
  alias FinTex.Model.Dialog
  alias FinTex.Segment.HKIDN
  alias FinTex.Segment.HKVVB
  alias FinTex.Segment.HNHBK
  alias FinTex.Segment.HNHBS
  alias FinTex.Segment.HNSHA
  alias FinTex.Segment.HNSHK
  alias FinTex.Service.ServiceBehaviour

  use AbstractCommand

  @behaviour ServiceBehaviour


  def has_capability?(_), do: true


  def update_accounts {seq, _} do
    request_segments = [
      %HNHBK{},
      %HNSHK{},
      %HKIDN{},
      %HKVVB{},
      %HNSHA{},
      %HNHBS{}
    ]

    {:ok, response} = seq |> Sequencer.call_http(request_segments)

    accounts = seq
    |> Sequencer.dialog
    |> accounts(response[:HIUPD])

    {seq |> Sequencer.update(dialog_id(response)) |> Sequencer.inc, accounts}
  end


  defp accounts(
    %Dialog{
      bank: bank,
      supported_tan_schemes: supported_tan_schemes,
      bpd: bpd,
      pintan: pintan
    },
    user_params) do

    offset = case bank.version do
      "300" -> 2
      _     -> 0
    end

    user_params

    |> Enum.map(fn u ->
      account = %Account{
        account_number:          u |> Enum.at(1) |> Enum.at(0),
        subaccount_id:           u |> Enum.at(1) |> Enum.at(1),
        blz:                     u |> Enum.at(1) |> Enum.at(3),
        currency:                u |> Enum.at(3 + offset),
        owner:                  [u |> Enum.at(4 + offset), u |> Enum.at(5 + offset)]
                                   |> Enum.join(" ")
                                   |> String.split
                                   |> Stream.map(&String.capitalize/1)
                                   |> Enum.join(" ")
                                   |> String.strip,
        name:                    u |> Enum.at(6 + offset),
        bank_name:               bpd
                                 |> Dict.get("HIBPA")
                                 |> Enum.at(0)
                                 |> Enum.at(3)
                                 |> String.strip,
        supported_transactions:  u
                                 |> Stream.drop(8 + offset)
                                 |> Stream.filter(fn l -> l |> is_list && !Enum.empty?(l) end)
                                 |> Stream.map(fn [transaction, _] -> transaction end)
                                 |> Stream.filter(fn transaction -> pintan |> Dict.has_key?(transaction) end)
                                 |> Stream.uniq
                                 |> Enum.sort,
        supported_tan_schemes:  supported_tan_schemes,
        preferred_tan_scheme:   supported_tan_schemes
                                 |> Stream.map(fn %TANScheme{sec_func: sec_func} -> sec_func end)
                                 |> Enum.at(0)
      }

      # add IBAN if available
      iban = case Enum.at(u, 2) do
        ""  -> nil
        els -> els
      end

      case bank.version do
        "300" -> %Account{account | iban: iban}
        _ -> account
      end

    end)
  end
end
