defprotocol FinTex.Model.Credentials do

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
