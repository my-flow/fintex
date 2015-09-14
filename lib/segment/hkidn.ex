defmodule FinTex.Segment.HKIDN do
  @moduledoc false

  alias FinTex.Model.Dialog

  defstruct [segment: nil]

  def new(_, d = %Dialog{
    bank:             bank,
    country_code:     country_code,
    client_id:        client_id,
    client_system_id: client_system_id}
  ) do

    client_system_status = case Dialog.anonymous?(d) do
      true  -> "0" # do not require a new client system ID
      false -> "1" # require a new client system ID
    end

    %__MODULE__{
      segment:
    		[
    			["HKIDN", "?", 2],
    			[country_code, bank.blz],
    			client_id,
    			client_system_id,
    			client_system_status
    		]
    }
  end
end


defimpl Inspect, for: FinTex.Segment.HKIDN do
  use FinTex.Helper.Inspect
end
