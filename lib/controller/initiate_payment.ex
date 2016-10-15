defmodule FinTex.Controller.InitiatePayment do
  @moduledoc false

  alias FinTex.Controller.Synchronization
  alias FinTex.Controller.Sequencer
  alias FinTex.Helper.Command
  alias FinTex.Model.Account
  alias FinTex.Model.Challenge
  alias FinTex.Model.ChallengeResponder
  alias FinTex.Model.TANScheme
  alias FinTex.Segment.HITAN
  alias FinTex.Segment.HKTAN
  alias FinTex.Segment.HNHBK
  alias FinTex.Segment.HNHBS
  alias FinTex.Segment.HNSHA
  alias FinTex.Segment.HNSHK

  use Command

  @spec initiate_payment(Sequencer.t, Account.t, %{}, %{}, ChallengeResponder.t) :: binary
  def initiate_payment(seq, account, %{tan_scheme: tan_scheme}, payment_segment, challenge_responder) do

    tan_scheme = account.supported_tan_schemes
    |> find_tan_scheme!(tan_scheme.sec_func, tan_scheme.medium_name)

    request_segments = [
      %HNHBK{},
      %HNSHK{},
      payment_segment,
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

    response[:HIRMG] |> Stream.concat(response[:HIRMS])
    |> format_messages
    |> Enum.join(", ")
  end


  # filter out valid HKTAN/HITANS segment version based on given sec_func
  defp find_tan_scheme!(supported_tan_schemes, sec_func, medium_name) do
    supported_tan_schemes = supported_tan_schemes
    |> Enum.filter(fn
      %TANScheme{sec_func: ^sec_func, medium_name_required: true, medium_name: ^medium_name} -> true
      %TANScheme{sec_func: ^sec_func, medium_name_required: false} -> true
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
