defprotocol FinTex.User.FinCredentials do

  @doc "user name"
  @spec login(t) :: String.t
  def login(credentials)


  @doc "client ID. Can be `nil`."
  @spec client_id(t) :: String.t | nil
  def client_id(credentials)


  @doc "personal identification number"
  @spec pin(t) :: String.t
  def pin(credentials)
end


defimpl FinTex.User.FinCredentials, for: [FinTex.Model.Credentials, Map] do

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


defimpl FinTex.User.FinCredentials, for: List do

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
