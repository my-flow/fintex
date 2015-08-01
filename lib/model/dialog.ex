defmodule FinTex.Model.Dialog do
  @moduledoc false

  alias FinTex.Config.Identifier

  @anonymous_login "9999999999"
  @max_sec_ref 99999999

  defstruct [
    :bank,
    :pin,
    country_code: Identifier.country_code,
    user_agent_name: Identifier.user_agent_name,
    user_agent_version: Identifier.user_agent_version,
    login: @anonymous_login,
    client_id: @anonymous_login,
    dialog_id: 0,
    message_no: 1,
    sec_ref: :random.uniform * @max_sec_ref |> round,
    client_system_id: "0",
    tan_scheme_sec_func: "999",
    bpd: HashDict.new,
    pintan: HashDict.new,
    supported_tan_schemes: []
  ]


  def new(bank, login, client_id, pin) do
    %__MODULE__{
      bank:       bank,
      login:      login,
      client_id:  client_id,
      pin:        pin
    }
  end


  def new(bank) do
    %__MODULE__{ bank: bank }
  end


  def anonymous?(%__MODULE__{login: login}) do
    login === @anonymous_login
  end


  def needs_synchronization?(d = %__MODULE__{client_system_id: client_system_id}) do
    !(d |> anonymous?) && client_system_id === "0"
  end


  def update(d = %__MODULE__{}, client_system_id, dialog_id, bpd, pintan, supported_tan_schemes)
  when is_binary(client_system_id) and is_binary(dialog_id) do

    %__MODULE__{d |
      dialog_id:              dialog_id,
      client_system_id:       client_system_id,
      bpd:                    bpd,
      pintan:                 pintan,
      supported_tan_schemes:  supported_tan_schemes
    }
  end


  def update(d = %__MODULE__{}, dialog_id) when is_binary(dialog_id) do
    %__MODULE__{d | dialog_id: dialog_id}
  end


  def inc(d = %__MODULE__{message_no: message_no, sec_ref: sec_ref})
  when is_integer(message_no) and is_integer(sec_ref) do

    %__MODULE__{d |
      message_no: message_no + 1,
      sec_ref:    sec_ref + 1
    }
  end


  def reset(d = %__MODULE__{tan_scheme_sec_func: tan_scheme_sec_func}, new_tan_scheme_sec_func \\ nil) do
    %__MODULE__{d |
      dialog_id: 0,
      message_no: 1,
      tan_scheme_sec_func: case new_tan_scheme_sec_func do
        nil -> tan_scheme_sec_func
        _   -> new_tan_scheme_sec_func
      end
    }
  end
end
