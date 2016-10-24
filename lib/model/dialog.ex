defmodule FinTex.Model.Dialog do
  @moduledoc false

  alias FinTex.Config.Identifier
  alias FinTex.Model.Bank

  @anonymous_login "9999999999"
  @max_sec_ref 99_999_999

  @type t :: %__MODULE__{
    bank: Bank.t,
    pin: binary,
    country_code: binary,
    user_agent_name: binary,
    user_agent_version: binary,
    login: binary,
    client_id: binary,
    dialog_id: non_neg_integer,
    message_no: pos_integer,
    sec_ref: non_neg_integer,
    client_system_id: binary,
    tan_scheme_sec_func: binary,
    bpd: map,
    pintan: map,
    supported_tan_schemes: list
  }

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
    sec_ref: :rand.uniform |> (&(&1 * @max_sec_ref)).() |> round,
    client_system_id: "0",
    tan_scheme_sec_func: "999",
    bpd: Map.new,
    pintan: Map.new,
    supported_tan_schemes: []
  ]


  def new(client_system_id, bank, login, client_id, pin) do
    %__MODULE__{
      client_system_id: client_system_id,
      bank:             bank,
      login:            login,
      client_id:        client_id,
      pin:              pin
    }
  end


  def new(client_system_id, bank) do
    %__MODULE__{
      client_system_id: client_system_id,
      bank:             bank
    }
  end


  def anonymous?(%__MODULE__{login: login}) do
    login === @anonymous_login
  end


  def update(d = %__MODULE__{}, client_system_id)
  when is_binary(client_system_id) do
    %__MODULE__{d | client_system_id: client_system_id}
  end


  def update(d = %__MODULE__{}, dialog_id, bpd, pintan, supported_tan_schemes) when is_binary(dialog_id) do
    %__MODULE__{d |
      dialog_id:              dialog_id,
      bpd:                    bpd,
      pintan:                 pintan,
      supported_tan_schemes:  supported_tan_schemes
    }
  end


  def inc(d = %__MODULE__{message_no: message_no, sec_ref: sec_ref})
  when is_integer(message_no) and is_integer(sec_ref) do

    %__MODULE__{d |
      message_no: message_no + 1,
      sec_ref:    sec_ref + 1
    }
  end


  def reset(d = %__MODULE__{tan_scheme_sec_func: tan_scheme_sec_func}, new_tan_scheme_sec_func) do
    %__MODULE__{d |
      tan_scheme_sec_func: case new_tan_scheme_sec_func do
        nil -> tan_scheme_sec_func
        _   -> new_tan_scheme_sec_func
      end
    }
  end
end
