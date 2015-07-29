defmodule FinTex.Command.FinPing do
  @moduledoc false

  alias FinTex.Command.AbstractCommand
  alias FinTex.Command.Sequencer
  alias FinTex.Segment.HKEND
  alias FinTex.Segment.HNHBK
  alias FinTex.Segment.HNHBS
  alias FinTex.Segment.HKIDN
  alias FinTex.Segment.HKVVB

  use AbstractCommand


  def ping(bank, options) do
    IO.puts "ping with #{bank.blz}"
    warn "Starting anonymous dialog with #{bank.blz}"

    seq = Sequencer.new(bank)

    request_segments = [
      %HNHBK{},
      %HKIDN{},
      %HKVVB{},
      %HNHBS{}
    ]

    {:ok, response} = seq |> Sequencer.call_http(request_segments)

    seq = seq |> Sequencer.update(dialog_id(response)) |> Sequencer.inc

    request_segments = [
      %HNHBK{},
      %HKEND{},
      %HNHBS{}
    ]

    {:ok} = seq |> Sequencer.call_http(request_segments, ignore_response: true)

    warn "Finishing anonymous dialog with #{bank.blz}"
  end
end
