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
  alias FinTex.Command.InitiateSEPACreditTransfer
  alias FinTex.Controller.Initialize
  alias FinTex.Model.Bank
  alias FinTex.Model.ChallengeResponder

  @type login :: binary
  @type client_id :: binary
  @type pin :: binary
  @type options :: []
  @type date_time :: DateTime.t

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


  @spec ping!(term, options) :: binary | no_return
  def ping!(bank, options \\ []) when is_list(options) do
    FinPing.ping(bank, options)
  end


  @spec ping(term, options) :: {:ok, binary} | {:error, term}
  def ping(bank, options \\ []) when is_list(options) do
    :ping! |> catch_errors([bank, options])
  end


  @spec new(term, term, options) :: t
  def new(bank, credentials, options \\ []) when is_list(options) do
    {_, d} = Initialize.initialize_dialog(bank, credentials, options)
    %__MODULE__{
      bank: d.bank,
      client_system_id: d.client_system_id,
      tan_scheme_sec_func: d.tan_scheme_sec_func
    }
  end


  @spec accounts!(t, term, options) :: Enumerable.t | no_return
  def accounts!(fintex, credentials, options \\ [])
  when is_list(options) do
    fintex |> GetAccountsInfo.get_account_info(credentials, options)
  end


  @spec accounts(t, term, options) :: {:ok, Enumerable.t} | {:error, binary}
  def accounts(fintex, credentials, options \\ [])
  when is_list(options) do
    :accounts! |> catch_errors([fintex, credentials, options])
  end


  @spec transactions!(t, term, term, date_time | nil, date_time | nil, options) ::
    Enumerable.t | no_return
  def transactions!(fintex, credentials, account, from \\ nil, to \\ nil, options \\ [])
  when is_list(options) do
    fintex |> GetTransactions.get_transactions(credentials, account, from, to, options)
  end


  @spec transactions(t, term, term, date_time | nil, date_time | nil, options)
    :: {:ok, Enumerable.t} | {:error, term}
  def transactions(fintex, credentials, account, from \\ nil, to \\ nil, options \\ [])
  when is_list(options) do
    :transactions! |> catch_errors([fintex, credentials, account, from, to, options])
  end


  @spec initiate_sepa_credit_transfer!(t, term, term, term, options)
    :: binary | no_return
  def initiate_sepa_credit_transfer!(fintex, credentials, sepa_credit_transfer, challenge_responder \\ ChallengeResponder, options \\ [])
  when is_list(options) do
    fintex |> InitiateSEPACreditTransfer.initiate_sepa_credit_transfer(credentials, sepa_credit_transfer,
      challenge_responder, options)
  end


  @spec initiate_sepa_credit_transfer(t, term, term, term, options)
    :: {:ok, binary} | {:error, term}
  def initiate_sepa_credit_transfer(fintex, credentials, sepa_credit_transfer, challenge_responder \\ ChallengeResponder, options \\ [])
  when is_list(options) do
    :initiate_sepa_credit_transfer! |> catch_errors([fintex, credentials, sepa_credit_transfer, challenge_responder,
      options])
  end


  @spec catch_errors(atom, [any]) :: {:ok, binary} | {:error, term}
  defp catch_errors(fun, args) when is_list(args) do
    try do
      {:ok, __MODULE__ |> apply(fun, args)}
    rescue
      e in FinTex.Error -> {:error, e.reason}
    end
  end
end
