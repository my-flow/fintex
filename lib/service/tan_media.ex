defmodule FinTex.Service.TANMedia do
  @moduledoc false

  alias FinTex.Command.Sequencer
  alias FinTex.Model.Account
  alias FinTex.Model.TANScheme
  alias FinTex.Segment.HITAB
  alias FinTex.Segment.HNHBK
  alias FinTex.Segment.HNSHK
  alias FinTex.Segment.HKTAB
  alias FinTex.Segment.HNSHA
  alias FinTex.Segment.HNHBS
  alias FinTex.Service.ServiceBehaviour

  @behaviour ServiceBehaviour


  def has_capability? %Account{supported_transactions: supported_transactions} do
    supported_transactions |> Enum.member?("HKTAB")
  end


  def update_accounts {seq, accounts} do
      request_segments = [
        %HNHBK{},
        %HNSHK{},
        %HKTAB{},
        %HNSHA{},
        %HNHBS{}
      ]
      {:ok, response} = seq |> Sequencer.call_http(request_segments)

      accounts = accounts
      |> Enum.map(fn {key, account} -> {key, account |> update(response[:HITAB] |> Enum.map(&HITAB.to_medium_name/1))} end)

      {seq |> Sequencer.inc, accounts}
  end


  defp update(account = %Account{supported_tan_schemes: supported_tan_schemes}, medium_names) do
    supported_tan_schemes = supported_tan_schemes
    |> Enum.map(fn tan_scheme -> %TANScheme{tan_scheme | medium_name:  medium_names |> Enum.at(0)} end)
    %Account{account | supported_tan_schemes: supported_tan_schemes}
  end
end
