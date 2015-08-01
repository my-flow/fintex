defmodule FinTex.Command.Facade do

  alias FinTex.Command.FinPing
  alias FinTex.Command.GetAccountsInfo
  alias FinTex.Command.GetTransactions
  alias FinTex.Command.InitiatePayment
  alias FinTex.Model.Account
  alias FinTex.Model.Bank
  alias FinTex.Model.ChallengeResponder
  alias FinTex.Model.Credentials
  alias FinTex.Model.Payment
  alias FinTex.User.FinChallengeResponder
  alias FinTex.User.FinBank
  alias FinTex.User.FinCredentials

  use Timex

  @type login :: binary
  @type client_id :: binary
  @type pin :: binary
  @type options :: []
  @type date_time :: %DateTime{}


  @spec ping(Bank.t, options) :: term
  def ping(bank, options \\ []) when is_list(options) do
    %{} = bank |> FinBank.from_bank |> validate!
    FinPing.ping(bank, options)
  end


  @spec accounts(Bank.t, Credentials.t, options) :: Enumerable.t
  def accounts(bank, credentials, options \\ []) when is_list(options) do
    %{} = bank = bank |> FinBank.from_bank |> validate!
    %{} = credentials = credentials |> FinCredentials.from_credentials |> validate!
    GetAccountsInfo.get_account_info(bank, credentials, options)
  end


  @spec transactions(Bank.t, Credentials.t, Account.t, date_time | nil, date_time | nil, options) :: Enumerable.t
  def transactions(bank, credentials, %Account{} = account, from \\ nil, to \\ nil, options \\ []) when is_list(options) do
    bank = bank |> FinBank.from_bank |> validate!
    credentials = credentials |> FinCredentials.from_credentials |> validate!
    GetTransactions.get_transactions(bank, credentials, account, from, to, options)
  end


  @spec initiate_payment(Bank.t, Credentials.t, Payment.t, ChallengeResponder.t, options) :: binary
  def initiate_payment(bank, credentials, %Payment{} = payment, challenge_responder \\ FinChallengeResponder, options \\ [])
  when is_list(options) do
    bank = bank |> FinBank.from_bank |> validate!
    credentials = credentials |> FinCredentials.from_credentials |> validate!
    %{} = payment |> validate!
    InitiatePayment.initiate_payment(bank, credentials, payment, challenge_responder, options)
  end


  defp validate!(valid_object) do
    case valid_object |> Vex.valid? do
      true  -> valid_object
      false -> raise ArgumentError, valid_object
      |> Vex.errors
      |> Enum.at(0)
      |> Tuple.to_list
      |> Enum.drop(1)
      |> Enum.join(" ")
    end
  end
end
