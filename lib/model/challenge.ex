defmodule FinTex.Model.Challenge do

  @moduledoc """
  The following fields are public:
    * `title`   - Challenge title
    * `label`   - Response label
    * `format`  - Challenge data format. Possible values are `:text`, `:html`, `:hhd` or `:matrix`.
    * `data`    - Challenge data
    * `medium`  - TAN medium
  """

  @type t :: %__MODULE__{
    title: binary,
    label: binary,
    format: atom,
    data: bitstring,
    medium: binary,
    ref: binary
  }

  defstruct [
    :title,
    :label,
    :format,
    :data,
    :medium,
    :ref
  ]

end
