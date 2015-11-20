defmodule FinTex.Service.AccountInfo do
  @moduledoc false

  alias FinTex.Command.AbstractCommand
  alias FinTex.Command.Sequencer
  alias FinTex.Model.Account
  alias FinTex.Segment.HKKIF
  alias FinTex.Segment.HNHBK
  alias FinTex.Segment.HNHBS
  alias FinTex.Segment.HNSHA
  alias FinTex.Segment.HNSHK
  alias FinTex.Service.AbstractService
  alias FinTex.Service.ServiceBehaviour

  use AbstractCommand
  use AbstractService

  @behaviour ServiceBehaviour


  def has_capability?(_, %Account{supported_transactions: supported_transactions}) do
    supported_transactions |>  Enum.member?("HKKIF")
  end


  def update_account(seq, account = %Account{}) do
    {seq, account_infos} = seq |> check_account_info(account, [])

    account_info = account_infos |> Enum.at(0)
    account = %Account{account | type: account_info |> Enum.at(2) |> String.to_integer |> to_account_type}

    {seq, account}
  end


  defp check_account_info(seq, account, account_infos, start_point \\ nil) do
    request_segments = [
      %HNHBK{},
      %HNSHK{},
      %HKKIF{account: account, start_point: start_point},
      %HNSHA{},
      %HNHBS{}
    ]

    {:ok, response} = seq |> Sequencer.call_http(request_segments)

    account_infos = account_infos |> Stream.concat(response[:HIKIF])

    start_point = response[:HIRMS]
    |> to_messages
    |> Stream.filter_map(fn [code | _] -> code === 3040 end, fn [_code, _ref, _text, start_point] -> start_point end)
    |> Enum.at(0)

    seq = seq |> Sequencer.inc

    case start_point do
      nil -> {seq, account_infos}
      _   -> check_account_info(seq, account, account_infos, start_point)
    end
  end


  defp to_account_type(type) when type >=  1 and type <=  9, do: :giro_account
  defp to_account_type(type) when type >= 10 and type <= 19, do: :savings_account
  defp to_account_type(type) when type >= 20 and type <= 29, do: :savings_account
  defp to_account_type(type) when type >= 30 and type <= 39, do: :depot
  defp to_account_type(type) when type >= 40 and type <= 49, do: :loan_account
  defp to_account_type(type) when type >= 50 and type <= 59, do: :credit_card
  defp to_account_type(type) when type >= 60 and type <= 69, do: :savings_account
  defp to_account_type(type) when type >= 70 and type <= 79, do: :depot
  defp to_account_type(type) when type >= 80 and type <= 89, do: :unknown
  defp to_account_type(type) when type >= 90 and type <= 99, do: :unknown
end
