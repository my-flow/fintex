defmodule FinTex.Model.Credentials do
  @moduledoc """
    Provides a default implementation of the `FinTex.User.FinCredentials` protocol.

    The following fields are public:
    * `login`     - user name
    * `client_id` - client ID. Can be `nil`.
    * `pin`       - personal identification number
  """

  alias FinTex.User.FinCredentials

  @type t :: %__MODULE__{
    login: binary,
    client_id: binary | nil,
    pin: binary
  }

  defstruct [
    :login,
    :client_id,
    :pin
  ]

  use Vex.Struct

  validates :login, presence: true,
                    length: [min: 1, max: 255]

  validates :client_id, length: [min: 1, max: 255, allow_nil: true]

  validates :pin, presence: true,
                  length: [min: 1, max: 255]

  @doc false
  @spec from_fin_credentials(term) :: t
  def from_fin_credentials(fin_credentials) do
    %__MODULE__{
      login:     fin_credentials |> FinCredentials.login,
      client_id: pick_if_set(fin_credentials |> FinCredentials.login, fin_credentials |> FinCredentials.client_id),
      pin:       fin_credentials |> FinCredentials.pin
    }
  end


  defp pick_if_set(login, nil), do: login

  defp pick_if_set(_, client_id), do: client_id

end
