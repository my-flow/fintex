defmodule FinTex.Command.InitiateSEPACreditTransfer do
  @moduledoc false

  alias FinTex.Controller.InitiatePayment
  alias FinTex.Controller.Synchronization
  alias FinTex.Data.AccountHandler
  alias FinTex.Helper.Command
  alias FinTex.Model.Bank
  alias FinTex.Model.Credentials
  alias FinTex.Model.SEPACreditTransfer
  alias FinTex.Segment.HKCCS

  use Command

  @type options :: []
  @type client_system_id :: binary


  @spec initiate_sepa_credit_transfer(FinTex.t, term, term, term, options) :: binary
  def initiate_sepa_credit_transfer(fintex, credentials, %{tan_scheme: tan_scheme}
    = sepa_credit_transfer, challenge_responder, options) do

    %{bank: bank, client_system_id: client_system_id} = fintex
    bank = bank |> Bank.from_bank |> validate!
    credentials = credentials |> Credentials.from_credentials |> validate!
    sepa_credit_transfer = sepa_credit_transfer |> SEPACreditTransfer.from_sepa_credit_transfer |> validate!

    {seq, accounts} = Synchronization.synchronize(bank, client_system_id, tan_scheme.sec_func, credentials, options)

    sender_account = accounts |> AccountHandler.find_account(sepa_credit_transfer.sender_account)

    sepa_credit_transfer = if sender_account do
       %SEPACreditTransfer{sepa_credit_transfer | sender_account: sender_account}
    else
      raise FinTex.Error, reason: "could not find sender account: #{inspect sepa_credit_transfer.sender_account}"
    end

    unless sender_account.supported_transactions |> Enum.into(MapSet.new) |> MapSet.member?("HKCCS") do
      raise FinTex.Error, reason:
        "could not find \"HKCCS\" in sender account's supported transactions: " <>
        "#{inspect sender_account.supported_transactions}"
    end

    InitiatePayment.initiate_payment(seq, sender_account, sepa_credit_transfer,
      %HKCCS{sepa_credit_transfer: sepa_credit_transfer}, challenge_responder)
  end
end
