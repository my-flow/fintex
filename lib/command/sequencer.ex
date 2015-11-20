defmodule FinTex.Command.Sequencer do
  @moduledoc false

  alias FinTex.Command.AbstractCommand
  alias FinTex.Connection.HTTPBody
  alias FinTex.Connection.HTTPClient
  alias FinTex.Model.Dialog

  use AbstractCommand
  import Supervisor.Spec
  require Record

  @type t :: record(:state, sup: pid, dialog: term, options: list)
  Record.defrecordp :state,
    sup: nil,
    dialog: nil,
    options: nil


  def new(client_system_id \\ "0", bank = %{}, credentials \\ nil, options)
  when is_list(options) do

    children = [
      worker(HTTPClient, [[]], restart: :transient)
    ]
    {:ok, sup} = Supervisor.start_link(children, strategy: :simple_one_for_one)

    {_, _, _} = :random.seed

    d = cond do 
      credentials -> Dialog.new(client_system_id, bank, credentials.login, credentials.client_id, credentials.pin)
      true        -> Dialog.new(client_system_id, bank)
    end
    state(sup: sup, dialog: d, options: options)
  end


  def call_http(state(sup: sup, dialog: %Dialog{bank: bank} = d, options: options), request_segments, opts \\ []) do
    options = Dict.merge(options, opts)
    {:ok, worker_pid} = Supervisor.start_child(sup, [])

    try do
      request_segments = request_segments |> Enum.map(&create(&1, d))
      request_segments |> inspect(binaries: :as_strings, pretty: true, limit: :infinity) |> debug
      body = request_segments |> HTTPBody.encode_body(d)
      result = HTTPClient.send_request(worker_pid, bank.url, body, options)

      case result do
        {:ok, response_body} ->
          response = HTTPBody.decode_body(response_body)
          response |> inspect(pretty: true, limit: :infinity) |> debug
          Stream.concat(response[:HIRMG], response[:HIRMS])
          |> to_messages
          |> check_messages_for_errors
          {:ok, response}
        :ok ->
          {:ok}
        {:error, msg} ->
          error msg
          raise FinTex.Error, reason: msg
      end
    after
      :ok = Supervisor.terminate_child(sup, worker_pid)
    catch
      :exit, msg -> :ok = Supervisor.terminate_child(sup, worker_pid)
      raise FinTex.Error, reason: msg
    end
  end


  def dialog(state(dialog: d)) do
    d
  end


  def update(state = state(dialog: d), client_system_id)
  when is_binary(client_system_id) do
    d = d |> Dialog.update(client_system_id)
    state(state, dialog: d)
  end


  def update(state = state(dialog: d), dialog_id, bpd \\ nil, pintan \\ nil, supported_tan_schemes \\ nil)
  when is_binary(dialog_id) do
    d = d |> Dialog.update(dialog_id, bpd, pintan, supported_tan_schemes)
    state(state, dialog: d)
  end


  def inc(state = state(dialog: d)) do
    d = d |> Dialog.inc
    state(state, dialog: d)
  end


  def reset(state = state(dialog: d), tan_scheme_sec_func) do
    d = d |> Dialog.reset(tan_scheme_sec_func)
    state(state, dialog: d)
  end
end
