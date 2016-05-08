defmodule FinTex.Command.InitiatePayment do
  @moduledoc false

  alias FinTex.Command.AbstractCommand
  alias FinTex.Command.Synchronization
  alias FinTex.Command.Sequencer
  alias FinTex.Data.AccountHandler
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

  use AbstractCommand
  import AccountHandler

  @type options :: []
  @type client_system_id :: binary


  @spec initiate_payment(Bank.t, client_system_id, Credentials.t, Payment.t, ChallengeResponder.t, options) :: binary
  def initiate_payment(bank, client_system_id, credentials, %Payment{tan_scheme: tan_scheme} = payment, challenge_responder, options) do

    {seq, accounts} = Synchronization.synchronize(bank, client_system_id, tan_scheme.sec_func, credentials, options)

    sender_account = accounts |> find_account(payment.sender_account)

    if sender_account do
      payment = %Payment{payment | sender_account: sender_account}
    else
      raise FinTex.Error, reason: "could not find sender account: #{inspect payment.sender_account}"
    end

    unless sender_account.supported_transactions |> Enum.into(MapSet.new) |> MapSet.member?("HKCCS") do
      raise FinTex.Error, reason:
        "could not find \"HKCCS\" in sender account's supported transactions: #{inspect sender_account.supported_transactions}"
    end

    tan_scheme = sender_account.supported_tan_schemes |> find_tan_scheme!(tan_scheme.sec_func, tan_scheme.medium_name)

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

    response_string = challenge_responder |> apply(:read_user_input, [challenge])

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

    %{} = Task.async(fn -> seq |> Synchronization.terminate end)

    Stream.concat(response[:HIRMG], response[:HIRMS])
    |> format_messages
    |> Enum.join(", ")
  end


  # filter out valid HKTAN/HITANS segment version based on given sec_func
  defp find_tan_scheme!(supported_tan_schemes, sec_func, medium_name) do
    supported_tan_schemes = supported_tan_schemes
    |> Enum.filter(fn
      %TANScheme{sec_func: ^sec_func, medium_name: ^medium_name} -> true
      _ -> false
    end)

    if supported_tan_schemes |> Enum.empty? do
      raise FinTex.Error, reason:
        "could not find supported TAN scheme for sec_func: #{inspect sec_func}, medium_name: #{inspect medium_name}"
    end

    # find maximum version of supported TAN schemes
    supported_tan_schemes
    |> Enum.max_by(fn %TANScheme{v: v} -> v end)
  end
end
