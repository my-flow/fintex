defmodule FinTex.User.FinCredentials do
  @moduledoc """
    Provides a default implementation of the `FinTex.Model.Credentials` protocol.

    The following fields are public:
    * `login`     - user name
    * `client_id` - client ID. Can be `nil`.
    * `pin`       - personal identification number
  """

  alias FinTex.Model.Credentials

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
  @spec from_credentials(Credentials.t) :: t
  def from_credentials(credentials) do
    %__MODULE__{
      login:     credentials |> Credentials.login,
      client_id: client_id(credentials |> Credentials.login, credentials |> Credentials.client_id),
      pin:       credentials |> Credentials.pin
    }
  end


  defp client_id(login, nil), do: login

  defp client_id(_, client_id), do: client_id

end


defimpl FinTex.Model.Credentials, for: [FinTex.User.FinCredentials, Map] do

  def login(credentials) do
    credentials |> Map.get(:login)
  end


  def client_id(credentials) do
    credentials |> Map.get(:client_id)
  end


  def pin(credentials) do
    credentials |> Map.get(:pin)
  end
end


defimpl FinTex.Model.Credentials, for: List do

  def login(credentials) do
    credentials |> Keyword.get(:login)
  end


  def client_id(credentials) do
    credentials |> Keyword.get(:client_id)
  end


  def pin(credentials) do
    credentials |> Keyword.get(:pin)
  end
end
