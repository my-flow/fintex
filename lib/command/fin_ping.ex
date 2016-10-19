defmodule FinTex.Command.FinPing do
  @moduledoc false

  alias FinTex.Controller.Sequencer
  alias FinTex.Helper.Command
  alias FinTex.Model.Bank
  alias FinTex.Segment.HKEND
  alias FinTex.Segment.HKIDN
  alias FinTex.Segment.HKVVB
  alias FinTex.Segment.HNHBK
  alias FinTex.Segment.HNHBS

  use Command

  @type options :: []


  @spec ping(term, options) :: binary | no_return
  def ping(bank, options) do
    %{} = bank = bank |> Bank.from_fin_bank |> validate!

    seq = Sequencer.new(bank, options)

    request_segments = [
      %HNHBK{},
      %HKIDN{},
      %HKVVB{},
      %HNHBS{}
    ]

    {:ok, response} = seq |> Sequencer.call_http(request_segments)

    seq = seq
    |> Sequencer.update(dialog_id(response))
    |> Sequencer.inc

    request_segments = [
      %HNHBK{},
      %HKEND{},
      %HNHBS{}
    ]

    :ok = seq |> Sequencer.call_http(request_segments, ignore_response: true)

    response[:HIRMG]
    |> Stream.concat(response[:HIRMS])
    |> format_messages
    |> Enum.join(", ")
  end
end
