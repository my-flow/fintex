defmodule FinTex.Command.Sequencer do
  @moduledoc false

  alias FinTex.Command.AbstractCommand
  alias FinTex.Connection.HTTPBody
  alias FinTex.Connection.HTTPClient
  alias FinTex.Model.Dialog

  use AbstractCommand
  import Supervisor.Spec
  require Record

  Record.defrecordp :state,
    sup: nil,
    dialog: nil


  def new(bank, login \\ nil, client_id \\ nil, pin \\ nil) do
    children = [
      worker(HTTPClient, [[]], restart: :transient)
    ]
    {:ok, sup} = Supervisor.start_link(children, strategy: :simple_one_for_one)

    {_, _, _} = :random.seed

    d = cond do 
      login && pin -> Dialog.new(bank, login, client_id, pin)
      true         -> Dialog.new(bank)
    end
    state(sup: sup, dialog: d)
  end


  def call_http(state(sup: sup, dialog: d), request_segments, options \\ []) do
    {:ok, worker_pid} = Supervisor.start_child(sup, [])

    try do
      request_segments = request_segments |> Enum.map(&create(&1, d))
      body = HTTPBody.encode_body(request_segments, d)
      result = HTTPClient.send_request(worker_pid, d.bank.url, body, options)

      case result do
        {:ok, response_body} ->
          response = HTTPBody.decode_body(response_body)
          debug inspect(response, pretty: true, limit: :infinity)
          Stream.concat(response[:HIRMG], response[:HIRMS]) |> messages |> format_messages
          {:ok, response}
        :ok ->
          {:ok}
        {:error, msg} ->
          warn msg
          {:error, msg}
      end
    after
      :ok = Supervisor.terminate_child(sup, worker_pid)
    catch
      :exit, msg -> :ok = Supervisor.terminate_child(sup, worker_pid)
      {:error, msg}
    end
  end


  def dialog(state(dialog: d)) do
    d
  end


  def needs_synchronization?(state(dialog: d)) do
    d |> Dialog.needs_synchronization?
  end


  def update(state = state(dialog: d), client_system_id, dialog_id, bpd, pintan, supported_tan_schemes)
  when is_binary(client_system_id) and is_binary(dialog_id) do
    d = d |> Dialog.update(client_system_id, dialog_id, bpd, pintan, supported_tan_schemes)
    state(state, dialog: d)
  end


  def update(state = state(dialog: d), dialog_id) when is_binary(dialog_id) do
    d = d |> Dialog.update(dialog_id)
    state(state, dialog: d)
  end


  def inc(state = state(dialog: d)) do
    d = d |> Dialog.inc
    state(state, dialog: d)
  end


  def reset(state = state(dialog: d), tan_scheme_sec_funcs) do
    d = d |> Dialog.reset(tan_scheme_sec_funcs)
    state(state, dialog: d)
  end


  defp format_messages(messages) do
    messages
    |> Stream.map(fn [code, _ref, text | params] -> "#{code} #{text} #{Enum.join(params, ", ")}" end)
    |> Enum.each(&warn/1)

    case messages |> Enum.at(0) do
      [code, _ref, text | _params] when code >= 9000 ->
        raise RuntimeError, message: "#{code} #{text}"
      _ ->
    end
  end
end
