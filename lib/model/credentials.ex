defprotocol FinTex.Model.Credentials do

  @doc "user name"
  @spec login(t) :: binary
  def login(credentials)


  @doc "client ID. Can be `nil`."
  @spec client_id(t) :: binary | nil
  def client_id(credentials)


  @doc "personal identification number"
  @spec pin(t) :: binary
  def pin(credentials)
end
