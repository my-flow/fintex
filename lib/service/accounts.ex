defmodule FinTex.Service.Accounts do
  @moduledoc false

  alias FinTex.Command.AbstractCommand
  alias FinTex.Command.Sequencer
  alias FinTex.Data.AccountHandler
  alias FinTex.Model.Account
  alias FinTex.Model.TANScheme
  alias FinTex.Model.Dialog
  alias FinTex.Segment.HITANS
  alias FinTex.Segment.HKIDN
  alias FinTex.Segment.HKVVB
  alias FinTex.Segment.HNHBK
  alias FinTex.Segment.HNHBS
  alias FinTex.Segment.HNSHA
  alias FinTex.Segment.HNSHK
  alias FinTex.Service.ServiceBehaviour

  use AbstractCommand
  import AccountHandler

  @behaviour ServiceBehaviour
  @allowed_methods 3920


  def has_capability?(_, _), do: true


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

    bpd = response[4]
    |> Enum.group_by(Map.new, fn [[name | _] | _] -> name end)


    pintan = bpd |> Map.get("HKPIN" |> control_structure_to_bpd)

    pintan = case pintan do
      nil -> bpd
             |> Map.new(fn {k, v} -> {k |> bpd_to_control_structure, v} end)
      _   -> pintan
             |> Enum.at(0)
             |> Enum.at(4)
             |> Enum.at(5)
             |> Stream.map(fn {k, _} -> k end)
             |> Map.new(fn name -> {name, bpd[name |> control_structure_to_bpd]} end)
    end

    tan_scheme_sec_funcs = response[:HIRMS]
    |> to_messages
    |> Stream.filter(fn [code | _] -> code === @allowed_methods end)
    |> Stream.map(fn [_, _, _ | params] -> params end)
    |> Enum.at(0)
    |> Enum.into(HashSet.new)

    supported_tan_schemes = pintan
    |> Map.get("HKTAN")
    |> Stream.flat_map(&HITANS.to_tan_schemes(&1))
    |> Stream.filter(fn %TANScheme{sec_func: sec_func} -> tan_scheme_sec_funcs |> Set.member?(sec_func) end)
    |> Enum.uniq_by(fn %TANScheme{sec_func: sec_func} -> sec_func end)

    seq = seq
    |> Sequencer.inc
    |> Sequencer.update(dialog_id(response), bpd, pintan, supported_tan_schemes)

    accounts = seq
    |> Sequencer.dialog
    |> accounts(response[:HIUPD])
    |> to_accounts_map

    {seq, accounts}
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

    |> Stream.map(fn u ->
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
                                 |> Map.get("HIBPA")
                                 |> Enum.at(0)
                                 |> Enum.at(3)
                                 |> String.strip,
        supported_transactions:  u
                                 |> Stream.drop(8 + offset)
                                 |> Stream.filter(fn l -> l |> is_list && !Enum.empty?(l) end)
                                 |> Stream.map(fn [transaction, _] -> transaction end)
                                 |> Stream.filter(fn transaction -> pintan |> Map.has_key?(transaction) end)
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
