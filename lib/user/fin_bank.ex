defmodule FinTex.User.FinBank do
  @moduledoc """
    Provides a default implementation of the `FinTex.Model.Bank` protocol.

    The following fields are public:
    * `blz`     - 8 digits bank code
    * `url`     - URL of the bank server
    * `version` - API version. Possible values are `220` or `300`.
  """

  alias FinTex.Model.Bank

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

  validates :blz, presence: true,
                  format: [with: ~r/^\d{8}$/, message: "must be an 8 digits number"]

  validates :url, uri: true

  validates :version, presence: true,
                      inclusion: ["220", "300"]

  @doc false
  @spec from_bank(Bank.t) :: t
  def from_bank(bank) do
    %__MODULE__{
      blz:      bank |> Bank.blz,
      url:      bank |> Bank.url,
      version:  bank |> Bank.version
    }
  end
end


defimpl FinTex.Model.Bank, for: FinTex.User.FinBank do

  def blz(bank) do
    bank.blz
  end


  def url(bank) do
    bank.url
  end


  def version(bank) do
    bank.version
  end
end
