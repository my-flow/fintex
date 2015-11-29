defmodule FinTex.Command.FinPing do
  @moduledoc false

  alias FinTex.Command.AbstractCommand
  alias FinTex.Command.Sequencer
  alias FinTex.Segment.HKEND
  alias FinTex.Segment.HKIDN
  alias FinTex.Segment.HKVVB
  alias FinTex.Segment.HNHBK
  alias FinTex.Segment.HNHBS

  use AbstractCommand


  def ping(bank, options) do
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

    Stream.concat(response[:HIRMG], response[:HIRMS])
    |> format_messages
    |> Enum.join(", ")
  end
end
