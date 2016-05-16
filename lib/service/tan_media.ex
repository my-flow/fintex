defmodule FinTex.Service.TANMedia do
  @moduledoc false

  alias FinTex.Command.AbstractCommand
  alias FinTex.Command.Sequencer
  alias FinTex.Model.Account
  alias FinTex.Model.TANMedium
  alias FinTex.Model.TANScheme
  alias FinTex.Segment.HITAB
  alias FinTex.Segment.HNHBK
  alias FinTex.Segment.HNSHK
  alias FinTex.Segment.HKTAB
  alias FinTex.Segment.HNSHA
  alias FinTex.Segment.HNHBS
  alias FinTex.Service.ServiceBehaviour

  use AbstractCommand

  @behaviour ServiceBehaviour


  def has_capability? {seq, accounts} do
    %Dialog{bpd: bpd} = seq
    |> Sequencer.dialog

    bpd
    |> Map.has_key?("HKTAB" |> control_structure_to_bpd)
    &&
    accounts
    |> Map.values
    |> Enum.flat_map(fn %Account{supported_tan_schemes: tan_schemes} -> tan_schemes end)
    |> Enum.any?(fn %TANScheme{medium_name_required: medium_name_required} -> medium_name_required end)
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
      |> Enum.map(fn {key, account} ->
          {key, account |> update(response[:HITAB] |> Enum.flat_map(&HITAB.to_tan_media/1))}
        end)
      |> Map.new

      {seq |> Sequencer.inc, accounts}
  end


  defp update(account = %Account{supported_tan_schemes: supported_tan_schemes}, tan_media) do
    supported_tan_schemes =
      for tan_scheme <- supported_tan_schemes,
      tan_medium <- tan_media,
      supported?(tan_scheme, tan_medium) do
        %TANScheme{tan_scheme | medium_name: tan_medium.name}
      end

    %Account{account | supported_tan_schemes: supported_tan_schemes}
  end


  defp supported?(%TANScheme{medium_name_required: true, format: format}, %TANMedium{format: format}) do
    true
  end

  defp supported?(%TANScheme{medium_name_required: true}, %TANMedium{format: :all}) do
    true
  end

  defp supported?(_, _), do: false

end
