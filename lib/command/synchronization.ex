defmodule FinTex.Command.Synchronization do
  @moduledoc false

  alias FinTex.Command.AbstractCommand
  alias FinTex.Command.Sequencer
  alias FinTex.Model.Account
  alias FinTex.Model.Dialog
  alias FinTex.Model.TANScheme
  alias FinTex.Segment.HITANS
  alias FinTex.Segment.HKEND
  alias FinTex.Segment.HKIDN
  alias FinTex.Segment.HKSYN
  alias FinTex.Segment.HKVVB
  alias FinTex.Segment.HNHBK
  alias FinTex.Segment.HNHBS
  alias FinTex.Segment.HNSHA
  alias FinTex.Segment.HNSHK
  alias FinTex.Segment.HKSPA


  @allowed_methods 3920

  use AbstractCommand

  def initialize_dialog(bank, credentials, tan_scheme_sec_func \\ nil, options) when is_list(options) do
    seq = Sequencer.new(bank, credentials, options)

    case seq |> Sequencer.needs_synchronization? do
      true  -> seq |> synchronize(tan_scheme_sec_func)
      false -> seq
    end
  end


  def terminate_dialog(seq) do
    request_segments = [
      %HNHBK{},
      %HNSHK{},
      %HKEND{},
      %HNSHA{},
      %HNHBS{}
    ]
    {:ok, _} = seq |> Sequencer.call_http(request_segments)
  end


  defp synchronize(seq, tan_scheme_sec_func) do
    request_segments = [
      %HNHBK{},
      %HNSHK{},
      %HKIDN{},
      %HKVVB{},
      %HKSYN{},
      %HNSHA{},
      %HNHBS{}
    ]

    {:ok, response} = seq |> Sequencer.call_http(request_segments)

    bpd = response[4]
    |> Enum.group_by(HashDict.new, fn [[name | _] | _] -> name end)


    pintan = bpd |> Dict.get("HKPIN" |> control_structure_to_bpd)

    pintan = case pintan do
      nil -> bpd
             |> Enum.map(fn {k, v} -> {k |> bpd_to_control_structure, v} end)
             |> Enum.into(HashDict.new)
      _   -> pintan
             |> Enum.at(0)
             |> Enum.at(4)
             |> Enum.at(5)
             |> Stream.map(fn {k, _} -> k end)
             |> Stream.map(fn name -> {name, bpd[name |> control_structure_to_bpd]} end)
             |> Enum.into(HashDict.new)
    end

    tan_scheme_sec_funcs = response[:HIRMS]
    |> messages
    |> Stream.filter(fn [code | _] -> code === @allowed_methods end)
    |> Stream.map(fn [_, _, _ | params] -> params end)
    |> Enum.at(0)
    |> Enum.into(HashSet.new)

    supported_tan_schemes = pintan
    |> Dict.get("HKTAN")
    |> Stream.flat_map(&HITANS.to_tan_schemes(&1))
    |> Stream.filter(fn %TANScheme{:sec_func => sec_func} -> tan_scheme_sec_funcs |> Set.member?(sec_func) end)
    |> Enum.uniq(fn %TANScheme{:sec_func => sec_func} -> sec_func end)

    seq = seq
    |> Sequencer.inc
    |> Sequencer.update(client_system_id(response), dialog_id(response),
      bpd, pintan, supported_tan_schemes)

    request_segments = [
      %HNHBK{},
      %HNSHK{},
      %HKEND{},
      %HNSHA{},
      %HNHBS{}
    ]

    {:ok} = seq |> Sequencer.call_http(request_segments, ignore_response: true)

    new_tan_scheme_sec_func = cond do
      tan_scheme_sec_func == nil and tan_scheme_sec_funcs |> HashSet.to_list == [] -> nil
      tan_scheme_sec_func == nil ->  tan_scheme_sec_funcs |> HashSet.to_list |> Enum.at(0)
      :else -> tan_scheme_sec_func
    end

    seq = seq
    |> Sequencer.reset(new_tan_scheme_sec_func)

    request_segments = [
      %HNHBK{},
      %HNSHK{},
      %HKIDN{},
      %HKVVB{},
      %HNSHA{},
      %HNHBS{}
    ]

    {:ok, response} = seq |> Sequencer.call_http(request_segments)

    seq = seq
    |> Sequencer.update(dialog_id(response))
    |> Sequencer.inc

    accounts = seq
    |> Sequencer.dialog
    |> accounts(response[:HIUPD])

    request_segments = [
      %HNHBK{},
      %HNSHK{},
      %HKSPA{},
      %HNSHA{},
      %HNHBS{}
    ]

    {:ok, response} = seq |> Sequencer.call_http(request_segments)

    accounts = add_sepa_data(accounts, response)

    seq = seq |> Sequencer.inc

    {seq, accounts}
  end


  defp client_system_id(response) do
    response[:HISYN] |> Enum.at(0) |> Enum.at(-1)
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
        :account_number         =>  u |> Enum.at(1) |> Enum.at(0),
        :subaccount_id          =>  u |> Enum.at(1) |> Enum.at(1),
        :blz                    =>  u |> Enum.at(1) |> Enum.at(3),
        :currency               =>  u |> Enum.at(3 + offset),
        :owner                  => [u |> Enum.at(4 + offset), u |> Enum.at(5 + offset)]
                                    |> Enum.join(" ")
                                    |> String.split
                                    |> Stream.map(&String.capitalize/1)
                                    |> Enum.join(" ")
                                    |> String.strip,
        :name                   =>  u |> Enum.at(6 + offset),
        :bank_name              =>  bpd
                                    |> Dict.get("HIBPA")
                                    |> Enum.at(0)
                                    |> Enum.at(3)
                                    |> String.strip,
        :supported_transactions =>  u
                                    |> Stream.drop(8 + offset)
                                    |> Stream.map(fn [transaction, _] -> transaction end)
                                    |> Stream.filter(fn transaction -> pintan |> Dict.has_key?(transaction) end)
                                    |> Enum.uniq,
        :supported_tan_schemes  => supported_tan_schemes,
        :preferred_tan_scheme   => supported_tan_schemes
                                    |> Stream.map(fn %TANScheme{:sec_func => sec_func} -> sec_func end)
                                    |> Enum.at(0)
      }

      # add IBAN if available
      iban = case Enum.at(u, 2) do
        ""  -> nil
        els -> els
      end

      case bank.version do
        "300" -> %Account{account | :iban => iban}
        _ -> account
      end

    end)

    |> Stream.map(fn account = %Account{:account_number => account_number} -> {account_number, account} end)

    |> Enum.into(HashDict.new)
  end


  defp add_sepa_data(accounts, response) do
    response[:HISPA]
    |> Enum.at(0)
    |> Stream.drop(1)
    |> Stream.filter(fn info -> Enum.at(info, 0) === "J" end)
    |> Stream.map(fn info ->
        account = accounts |> Dict.get(Enum.at(info, 3))
        account = %Account{account |
          iban: Enum.at(info, 1),
          bic:  Enum.at(info, 2)
        }
        %{account_number: account_number} = account
        {account_number, account}
       end)
    |> Enum.into(accounts)
  end
end
