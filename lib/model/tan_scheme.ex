defmodule FinTex.Model.TANScheme do

  @moduledoc """
  The following fields are public:
    * `name`        - TAN scheme name
    * `medium_name` - TAN medium name
    * `sec_func`    - encoded security function
    * `format`      - Challenge data format. Possible values are `:text`, `:html`, `:hhd` or `:matrix`.
    * `label`       - response label
  """

  defstruct [
    :name,
    :medium_name,
    :sec_func,
    :format,
    :label,
    :v
  ]

  @type t :: %__MODULE__{}

end
