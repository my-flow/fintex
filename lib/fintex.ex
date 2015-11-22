defmodule FinTex do
  @moduledoc File.read!("README.md")

  defmacro __using__(_) do
    quote do
      Application.put_env(:vex, :sources, [FinTex.Validator, Vex.Validators])
    end
  end

  alias FinTex.Command.FinPing
  alias FinTex.Command.GetAccountsInfo
  alias FinTex.Command.GetTransactions
  alias FinTex.Command.Initialize
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

  @type t :: %__MODULE__{
    bank: Bank.t,
    client_system_id: binary,
    tan_scheme_sec_func: binary
  }

  defstruct [
    :bank,
    :tan_scheme_sec_func,
    client_system_id: "0",
  ]


  @spec ping!(Bank.t, options) :: binary | no_return
  def ping!(bank, options \\ []) when is_list(options) do
    %{} = bank = bank |> FinBank.from_bank |> validate!
    FinPing.ping(bank, options)
  end


  @spec ping(Bank.t, options) :: {:ok, binary} | {:error, term}
  def ping(bank, options \\ []) when is_list(options) do
    try do
      {:ok, ping!(bank, options)}
    rescue
      e in FinTex.Error -> {:error, e.reason}
    end
  end


  @spec new(Bank.t, Credentials.t, options) :: t
  def new(bank, credentials, options \\ []) when is_list(options) do
    %{} = bank = bank |> FinBank.from_bank |> validate!
    %{} = credentials = credentials |> FinCredentials.from_credentials |> validate!
    {_, d} = Initialize.initialize_dialog(bank, credentials, options)
    %__MODULE__{
      bank: bank,
      client_system_id: d.client_system_id,
      tan_scheme_sec_func: d.tan_scheme_sec_func
    }
  end


  @spec accounts!(t, Credentials.t, options) :: Enumerable.t | no_return
  def accounts!(fintex, credentials, options \\ [])
  when is_list(options) do
    %__MODULE__{bank: bank, tan_scheme_sec_func: tan_scheme_sec_func, client_system_id: client_system_id} = fintex
    %{} = credentials = credentials |> FinCredentials.from_credentials |> validate!
    GetAccountsInfo.get_account_info(bank, client_system_id, tan_scheme_sec_func, credentials, options)
  end


  @spec accounts(t, Credentials.t, options) :: {:ok, Enumerable.t} | {:error, binary}
  def accounts(fintex, credentials, options \\ [])
  when is_list(options) do
    try do
      {:ok, accounts!(fintex, credentials, options)}
    rescue
      e in FinTex.Error -> {:error, e.reason}
    end
  end


  @spec transactions!(t, Credentials.t, Account.t, date_time | nil, date_time | nil, options) :: Enumerable.t | no_return
  def transactions!(fintex, credentials, %Account{} = account, from \\ nil, to \\ nil, options \\ [])
  when is_list(options) do
    %__MODULE__{bank: bank, tan_scheme_sec_func: tan_scheme_sec_func, client_system_id: client_system_id} = fintex
    credentials = credentials |> FinCredentials.from_credentials |> validate!
    GetTransactions.get_transactions(bank, client_system_id, tan_scheme_sec_func, credentials, account, from, to, options)
  end


  @spec transactions(t, Credentials.t, Account.t, date_time | nil, date_time | nil, options) :: {:ok, Enumerable.t} | {:error, term}
  def transactions(fintex, credentials, %Account{} = account, from \\ nil, to \\ nil, options \\ [])
  when is_list(options) do
    try do
      {:ok, transactions!(fintex, credentials, account, from, to, options)}
    rescue
      e in FinTex.Error -> {:error, e.reason}
    end
  end


  @spec initiate_payment!(t, Credentials.t, Payment.t, ChallengeResponder.t, options) :: binary | no_return
  def initiate_payment!(fintex, credentials, %Payment{} = payment, challenge_responder \\ FinChallengeResponder, options \\ [])
  when is_list(options) do
    %__MODULE__{bank: bank, client_system_id: client_system_id} = fintex
    credentials = credentials |> FinCredentials.from_credentials |> validate!
    %{} = payment |> validate!
    InitiatePayment.initiate_payment(bank, client_system_id, credentials, payment, challenge_responder, options)
  end


  @spec initiate_payment(t, Credentials.t, Payment.t, ChallengeResponder.t, options) :: {:ok, binary} | {:error, term}
  def initiate_payment(fintex, credentials, %Payment{} = payment, challenge_responder \\ FinChallengeResponder, options \\ [])
  when is_list(options) do
    try do
      {:ok, initiate_payment!(fintex, credentials, payment, challenge_responder, options)}
    rescue
      e in FinTex.Error -> {:error, e.reason}
    end
  end


  defp validate!(valid_object) do
    case valid_object |> Vex.valid? do
      true  -> valid_object
      false -> raise FinTex.Error, reason: valid_object
      |> Vex.errors
      |> Enum.at(0)
      |> Tuple.to_list
      |> Enum.drop(1)
      |> Enum.join(" ")
    end
  end
end
