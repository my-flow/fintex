defmodule FinTex.Model.TANMedium do
  @moduledoc false

  @type t :: %__MODULE__{
    name: binary,
    format: atom
  }

  defstruct [
    :name,
    :format
  ]

end
