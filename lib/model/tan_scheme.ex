defmodule FinTex.Model.TANScheme do
  @moduledoc """
  The following fields are public:
    * `name`        - TAN scheme name
    * `medium_name` - TAN medium name
    * `sec_func`    - encoded security function
    * `format`      - Challenge data format. Possible values are `:text`, `:html`, `:hhd` or `:matrix`.
    * `label`       - response label
  """

  @type t :: %__MODULE__{
    name: binary,
    medium_name: binary,
    medium_name_required: boolean,
    sec_func: pos_integer,
    format: atom,
    label: binary,
    v: pos_integer
  }

  defstruct [
    :name,
    :medium_name,
    :medium_name_required,
    :sec_func,
    :format,
    :label,
    :v
  ]

end
