defmodule FinTex.Model.Bank do
  @moduledoc """
    Provides a default implementation of the `FinTex.User.FinBank` protocol.

    The following fields are public:
    * `blz`     - 8 digits bank code
    * `url`     - URL of the bank server
    * `version` - API version. Possible values are `220` or `300`.
  """

  alias FinTex.User.FinBank

  @type t :: %__MODULE__{
    blz: binary,
    url: binary,
    version: binary
  }

  defstruct [
    :blz,
    :url,
    :version
  ]

  use Vex.Struct

  validates :blz, presence: true, blz: true

  validates :url, uri: true

  validates :version, presence: true,
                      inclusion: ["220", "300"]

  @doc false
  @spec from_bank(term) :: t
  def from_bank(bank) do
    %__MODULE__{
      blz:      bank |> FinBank.blz,
      url:      bank |> FinBank.url,
      version:  bank |> FinBank.version
    }
  end
end
