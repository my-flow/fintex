defmodule FinTex.Segment.HKIDN do
  @moduledoc false

  alias FinTex.Model.Dialog

  defstruct []

  def create(_, d = %Dialog{
    :bank             => bank,
    :country_code     => country_code,
    :client_id        => client_id,
    :client_system_id => client_system_id}
  ) do

    client_system_status = case Dialog.anonymous?(d) do
      true  -> "0" # do not require a new client system ID
      false -> "1" # require a new client system ID
    end

		[
			["HKIDN", "?", 2],
			[country_code, bank.blz],
			client_id,
			client_system_id,
			client_system_status
		]
  end
end
