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
  @spec from_credentials(FinCredentials.t) :: t
  def from_credentials(credentials) do
    %__MODULE__{
      login:     credentials |> FinCredentials.login,
      client_id: pick_if_set(credentials |> FinCredentials.login, credentials |> FinCredentials.client_id),
      pin:       credentials |> FinCredentials.pin
    }
  end


  defp pick_if_set(login, nil), do: login

  defp pick_if_set(_, client_id), do: client_id

end
