defmodule FinTex.Command.InitiatePayment do
  @moduledoc false

  alias FinTex.Command.AbstractCommand
  alias FinTex.Command.Synchronization
  alias FinTex.Command.Sequencer
  alias FinTex.Model.Account
  alias FinTex.Model.Bank
  alias FinTex.Model.Challenge
  alias FinTex.Model.Payment
  alias FinTex.Model.TANScheme
  alias FinTex.Segment.HITAN
  alias FinTex.Segment.HITAB
  alias FinTex.Segment.HKCCS
  alias FinTex.Segment.HKTAB
  alias FinTex.Segment.HKTAN
  alias FinTex.Segment.HNHBK
  alias FinTex.Segment.HNHBS
  alias FinTex.Segment.HNSHA
  alias FinTex.Segment.HNSHK

  use AbstractCommand

  @type login :: String.t
  @type client_id :: String.t
  @type pin :: String.t
  @type options :: [timeout: timeout]


  @spec initiate_payment(Bank.t, login, client_id, pin, Payment.t, (Challenge.t -> any), options) :: binary
  def initiate_payment(bank, login, client_id, pin, payment, callback_fn, options)
  when is_function(callback_fn) and is_binary(login) and is_binary(client_id) and is_binary(pin) do

    {seq, accounts} = Synchronization.initialize_dialog(bank, login, client_id, pin, payment.tan_scheme.sec_func)

    sender_account = accounts
    |> Dict.values
    |> Enum.find(&find_account(payment.sender_account, &1))

    if sender_account do
      payment = %Payment{payment | sender_account: sender_account}
    else
      raise ArgumentError,
        "could not find sender account: #{inspect payment.sender_account}"
    end

    unless payment.sender_account.supported_transactions |> Enum.into(HashSet.new) |> Set.member?("HKCCS") do
      raise ArgumentError,
        "could not find \"HKCCS\" in sender account's supported transactions: #{inspect payment.sender_account.supported_transactions}"
    end

    # filter out valid HKTAN/HITANS segment version based on given sec_func
    valid_tan_schemes = (seq |> Sequencer.dialog).supported_tan_schemes
    |> Enum.filter(fn %TANScheme{:sec_func => sec_func} -> sec_func == payment.tan_scheme.sec_func end)

    if valid_tan_schemes |> Enum.count == 0 do
      raise ArgumentError,
        "could not find supported TAN scheme for sec_func: #{inspect payment.tan_scheme.sec_func}"
    end

    # find maximum version of supported TAN schemes
    tan_scheme = valid_tan_schemes
    |> Enum.max_by(fn %TANScheme{:v => v} -> v end)

    tan_medium_required = tan_scheme.medium_name == :required &&
    (seq |> Sequencer.dialog).pintan
    |> Dict.get("HKTAB" |> control_structure_to_bpd)

    if tan_medium_required do
      request_segments = [
        %HNHBK{},
        %HNSHK{},
        %HKTAB{},
        %HNSHA{},
        %HNHBS{}
      ]
      {:ok, response} = seq |> Sequencer.call_http(request_segments)
      tan_scheme = response[:HITAB] |> Enum.at(0) |> HITAB.to_tan_scheme(tan_scheme)
      seq = seq |> Sequencer.inc
    end

    request_segments = [
      %HNHBK{},
      %HNSHK{},
      %HKCCS{payment: payment},
      %HKTAN{v: tan_scheme.v, process: 4, medium_name: tan_scheme.medium_name},
      %HNSHA{},
      %HNHBS{}
    ]

    {:ok, response} = seq |> Sequencer.call_http(request_segments)

    challenge = response[:HITAN]
    |> Enum.at(0)
    |> HITAN.to_challenge(tan_scheme)

    response_string = callback_fn.(challenge)

    request_segments = [
      %HNHBK{},
      %HNSHK{},
      %HKTAN{v: tan_scheme.v, process: 2, ref: challenge.ref},
      %HNSHA{response: response_string},
      %HNHBS{}
    ]

    seq = seq |> Sequencer.inc

    {:ok, response} = seq |> Sequencer.call_http(request_segments)

    seq = seq |> Sequencer.inc

    %{} = Task.async(fn -> seq |> Synchronization.terminate_dialog end)

    Stream.concat(response[:HIRMG], response[:HIRMS])
    |> messages
    |> Stream.map(fn [code, _ref, text | params] -> "#{code} #{text} #{Enum.join(params, ", ")}" end)
    |> Enum.join(", ")
  end


  def find_account(
    %Account{iban: iban},
    %Account{iban: iban}
  ) when iban != nil
  do
    true
  end


  def find_account(
    %Account{account_number: account_number, subaccount_id: subaccount_id},
    %Account{account_number: account_number, subaccount_id: subaccount_id}
  ) when account_number != nil
  do
    true
  end


  def find_account(_, _), do: false
end
