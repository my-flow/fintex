defmodule FinTex.Controller.Initialize do
  @moduledoc false

  alias FinTex.Controller.Sequencer
  alias FinTex.Helper.Command
  alias FinTex.Model.Bank
  alias FinTex.Model.Credentials
  alias FinTex.Model.Dialog
  alias FinTex.Segment.HKEND
  alias FinTex.Segment.HKIDN
  alias FinTex.Segment.HKSYN
  alias FinTex.Segment.HKVVB
  alias FinTex.Segment.HNHBK
  alias FinTex.Segment.HNHBS
  alias FinTex.Segment.HNSHA
  alias FinTex.Segment.HNSHK

  @type options :: []
  @allowed_methods 3920

  use Command


  @spec initialize_dialog(term, term, options) :: any
  def initialize_dialog(bank, credentials, options) when is_list(options) do
    %{} = bank = bank |> Bank.from_fin_bank |> validate!
    %{} = credentials = credentials |> Credentials.from_fin_credentials |> validate!

    seq = Sequencer.new("0", bank, credentials, options)

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

    client_system_id = response[:HISYN]
    |> Enum.at(0)
    |> Enum.at(-1)

    tan_scheme_sec_func = response[:HIRMS]
    |> to_messages
    |> Stream.filter(fn [code | _] -> code === @allowed_methods end)
    |> Stream.map(fn [_, _, _ | params] -> params end)
    |> Enum.at(0)
    |> Enum.sort(&(&1 > &2)) # choose TAN scheme with highest identifier, closest to default TAN scheme "999"
    |> Enum.at(0)

    seq = seq
    |> Sequencer.inc
    |> Sequencer.update(client_system_id)
    |> Sequencer.reset(tan_scheme_sec_func)

    request_segments = [
      %HNHBK{},
      %HNSHK{},
      %HKEND{},
      %HNSHA{},
      %HNHBS{}
    ]

    :ok = seq |> Sequencer.call_http(request_segments, ignore_response: true)

    {seq, seq |> Sequencer.dialog}
  end
end
