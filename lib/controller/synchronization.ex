defmodule FinTex.Controller.Synchronization do
  @moduledoc false

  alias FinTex.Controller.Sequencer
  alias FinTex.Helper.Command
  alias FinTex.Model.Dialog
  alias FinTex.Segment.HKEND
  alias FinTex.Segment.HNHBK
  alias FinTex.Segment.HNHBS
  alias FinTex.Segment.HNSHA
  alias FinTex.Segment.HNSHK
  alias FinTex.Service.Accounts
  alias FinTex.Service.SEPAInfo
  alias FinTex.Service.TANMedia

  use Command

  @services [
    Accounts,
    SEPAInfo,
    TANMedia
  ]

  def synchronize(bank, client_system_id, tan_scheme_sec_func, credentials, options) when is_list(options) do
    seq = Sequencer.new(client_system_id, bank, credentials, options)

    seq = if tan_scheme_sec_func != nil, do: seq |> Sequencer.reset(tan_scheme_sec_func), else: seq

    @services
    |> Enum.reduce({seq, %{}}, fn(service, acc) ->
      apply(service, :check_capabilities_and_update_accounts, [acc])
    end)
  end


  def terminate(seq) do
    request_segments = [
      %HNHBK{},
      %HNSHK{},
      %HKEND{},
      %HNSHA{},
      %HNHBS{}
    ]
    {:ok, _} = seq |> Sequencer.call_http(request_segments)
  end
end
