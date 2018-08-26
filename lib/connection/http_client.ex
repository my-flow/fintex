defmodule FinTex.Connection.HTTPClient do
  @moduledoc false

  use ExActor.Strict
  import Logger

  defstruct [
    async_id: nil,
    from: nil,
    response: nil
  ]

  defstart start_link(url, body, options) do
    debug "Starting #{inspect __MODULE__}"
    state = send_request(url, body, options)
    initial_state state
  end


  defcall fetch, from: from, state: state = %{response: response}, timeout: :infinity do
    case response do
      nil -> new_state %{state | from: from}
      _ -> reply response
    end
  end


  defp send_request(url, body, options) do
    debug("#{inspect self}: sending request to URL #{url}")

    ssl_options = case options |> Keyword.get(:ssl_options, []) do
      [] ->
        []
      _ ->
        %URI{host: host} = URI.parse(url)
        hostname = to_charlist(host)
        {{module, function, arity}, initial_user_state} = options[:ssl_options][:verify_fun]
        verify_fun = :erlang.make_fun(module, function, arity)
        Keyword.merge(
          options[:ssl_options],
          [
            verify_fun: {
              verify_fun,
              List.keyreplace(initial_user_state, :check_hostname, 0, {:check_hostname, hostname})
            },
            server_name_indication: hostname
          ]
        )
    end

    ibrowse = [ssl_options: ssl_options]
    |> Keyword.merge(Keyword.get(options, :ibrowse, []))

    %HTTPotion.AsyncResponse{id: async_id} = HTTPotion.post(
      url,
      body: body,
      headers: [
          "Content-Type": "text/plain",
          "Connection":   "keep-alive"
      ],
      stream_to: self,
      ibrowse: ibrowse,
      timeout: options[:timeout]
    )

    %__MODULE__{async_id: async_id}
  end


  defhandleinfo %HTTPotion.AsyncHeaders{id: id, status_code: status_code},
  state: %{async_id: async_id}, export: false,
  when: id == async_id and (status_code in 200..299 or status_code in [302, 304]) do
    noreply
  end


  defhandleinfo %HTTPotion.AsyncChunk{id: id, chunk: chunk},
  state: state = %{from: from, async_id: async_id, response: response},
  export: false, when: id == async_id and is_binary(chunk) do
    response = response || {:ok, to_string(chunk)}
    if from, do: from |> GenServer.reply(response)
    new_state %__MODULE__{state | response: response}
  end


  defhandleinfo %HTTPotion.AsyncEnd{id: id},
  state: %{async_id: async_id},
  export: false, when: id == async_id do
    noreply
  end
end
