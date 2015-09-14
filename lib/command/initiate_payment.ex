defmodule FinTex.Command.InitiatePayment do
  @moduledoc false

  alias FinTex.Command.AbstractCommand
  alias FinTex.Command.Synchronization
  alias FinTex.Command.Sequencer
  alias FinTex.Model.Account
  alias FinTex.Model.Bank
  alias FinTex.Model.Challenge
  alias FinTex.Model.ChallengeResponder
  alias FinTex.Model.Credentials
  alias FinTex.Model.Payment
  alias FinTex.Model.TANScheme
  alias FinTex.Segment.HITAN
  alias FinTex.Segment.HKCCS
  alias FinTex.Segment.HKTAN
  alias FinTex.Segment.HNHBK
  alias FinTex.Segment.HNHBS
  alias FinTex.Segment.HNSHA
  alias FinTex.Segment.HNSHK
  alias FinTex.Service.TANMedia

  use AbstractCommand

  @type options :: []


  @spec initiate_payment(Bank.t, Credentials.t, Payment.t, ChallengeResponder.t, options) :: binary
  def initiate_payment(bank, credentials, %Payment{tan_scheme: tan_scheme} = payment, challenge_responder, options) do

    {seq, accounts} = Synchronization.initialize_dialog(bank, credentials, tan_scheme.sec_func, options)

    sender_account = accounts
    |> Dict.values
    |> Enum.find(&find_account(payment.sender_account, &1))

    if sender_account do
      payment = %Payment{payment | sender_account: sender_account}
    else
      raise ArgumentError,
        "could not find sender account: #{inspect payment.sender_account}"
    end

    unless sender_account.supported_transactions |> Enum.into(HashSet.new) |> Set.member?("HKCCS") do
      raise ArgumentError,
        "could not find \"HKCCS\" in sender account's supported transactions: #{inspect sender_account.supported_transactions}"
    end

    # filter out valid HKTAN/HITANS segment version based on given sec_func
    valid_tan_schemes = (seq |> Sequencer.dialog).supported_tan_schemes
    |> Enum.filter(fn %TANScheme{sec_func: sec_func} -> sec_func == tan_scheme.sec_func end)

    if valid_tan_schemes |> Enum.count == 0 do
      raise ArgumentError,
        "could not find supported TAN scheme for sec_func: #{inspect tan_scheme.sec_func}"
    end

    # find maximum version of supported TAN schemes
    tan_scheme = valid_tan_schemes
    |> Enum.max_by(fn %TANScheme{v: v} -> v end)

    tan_medium_required = tan_scheme.medium_name == :required && TANMedia.has_capability?(sender_account)

    if tan_medium_required do
      {seq, accounts} = TANMedia.update_accounts {seq, [sender_account]}
      tan_scheme = (accounts |> Enum.at(0)).supported_tan_schemes |> Enum.at(0)
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

    %Challenge{ref: ref} = challenge = response[:HITAN]
    |> Enum.at(0)
    |> HITAN.to_challenge(tan_scheme)

    response_string = apply(challenge_responder, :read_user_input, [challenge])

    request_segments = [
      %HNHBK{},
      %HNSHK{},
      %HKTAN{v: tan_scheme.v, process: 2, ref: ref},
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
