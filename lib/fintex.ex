defmodule FinTex do
  alias FinTex.Command.FinPing
  alias FinTex.Command.GetAccountsInfo
  alias FinTex.Command.GetTransactions
  alias FinTex.Command.InitiatePayment
  alias FinTex.Model.Account
  alias FinTex.Model.Bank
  alias FinTex.Model.Challenge
  alias FinTex.Model.Payment
  alias FinTex.Model.Transaction
  alias FinTex.User.ChallengeResponder


  @type login :: binary
  @type client_id :: binary
  @type pin :: binary
  @type options :: []


  @spec ping(Bank.t, options) :: term
  def ping(bank, options \\ []) when is_tuple(bank) and is_list(options) do
    FinPing.ping(bank, options)
  end


  @spec accounts(Bank.t, login, client_id, pin, options) :: [Account.t]
  def accounts(bank, login, client_id \\ nil, pin, options \\ [])
  when is_binary(login) and is_binary(pin) and is_list(options) do
    client_id = client_id(login, client_id)
    GetAccountsInfo.get_account_info(bank, login, client_id, pin, options) |> Enum.to_list
  end


  @spec transactions(Bank.t, login, client_id, pin, Account.t, options) :: [Transaction.t]
  def transactions(bank, login, client_id \\ nil, pin, account, options \\ [])
  when is_binary(login) and is_binary(pin) and is_list(options) do
    client_id = client_id(login, client_id)
    GetTransactions.get_transactions(bank, account, login, client_id, pin, options) |> Enum.to_list
  end


  @spec initiate_payment(Bank.t, login, client_id, pin, Payment.t, (Challenge.t -> any), options) :: binary
  def initiate_payment(bank, login, client_id \\ nil, pin, payment, callback_fn \\ &ChallengeResponder.read_user_input/1, options \\ [])
  when is_function(callback_fn) and is_binary(login) and is_binary(pin) and is_list(options) do
    client_id = client_id(login, client_id)
    InitiatePayment.initiate_payment(bank, login, client_id, pin, payment, callback_fn, options)
  end


  defp client_id(login, nil), do: login

  defp client_id(_, client_id), do: client_id
end
