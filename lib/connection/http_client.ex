defmodule FinTex.Connection.HTTPClient do
  @moduledoc false

  alias FinTex.Config.Identifier

  use ExActor.GenServer
  import Logger

  defstart start_link(_) do
    debug "Starting #{inspect __MODULE__}"
    HTTPotion.start
    initial_state nil
  end


  defcall send_request(url, body, options), from: from, timeout: :infinity do
    debug("#{inspect self}: sending request to URL #{url}")

    ssl_options = Application.get_env(:fintex, :ssl_options, [])
    |> Dict.merge Dict.get(options, :ssl_options, [])

    ssl_options = case ssl_options do
      [] ->
        []
      _ ->
        %URI{host: host} = URI.parse(url)
        hostname = to_char_list(host)
        {verify_fun, initial_user_state} = Dict.get(ssl_options, :verify_fun)        
        Dict.merge(
          [
            verify_fun: {
              verify_fun, 
              List.keyreplace(initial_user_state, :check_hostname, 0, {:check_hostname, hostname})
            },
            server_name_indication: hostname
          ],
          ssl_options
        )
    end

    ibrowse = [ssl_options: ssl_options]
    |> Dict.merge Application.get_env(:fintex, :ibrowse, [])
    |> Dict.merge Dict.get(options, :ibrowse, [])

    options = [ignore_response: false] |> Dict.merge options

    %HTTPotion.AsyncResponse{id: async_id} = HTTPotion.post(
      url,
      body: body,
      headers: [
          "Content-Type": "text/plain",
          "Connection":   "keep-alive",
          "User-Agent":   Identifier.user_agent_name
      ],
      stream_to: self,
      ibrowse: ibrowse,
      timeout: 10_000
    )

    if options[:ignore_response], do: GenServer.reply(from, :ok)
    new_state {from, async_id, options}
  end


  defhandleinfo %HTTPotion.AsyncHeaders{id: id, status_code: status_code},
  state: {_, async_id, _}, when: id == async_id and (status_code
  in 200..299 or status_code in [302, 304]), export: false do
    noreply
  end


  defhandleinfo %HTTPotion.AsyncHeaders{id: id, status_code: status_code},
  state: {from, async_id, options}, export: false, when: id == async_id do
    msg = "#{__MODULE__}: Request failed with HTTP status code #{status_code}."
    error msg
    if !options[:ignore_response] do
      GenServer.reply(from, {:error, msg})
      raise RuntimeError, message: msg
    end
    noreply
  end


  defhandleinfo %HTTPotion.AsyncChunk{id: id, chunk: {:error, msg}},
  state: {from, async_id, options}, export: false, when: id == async_id do

    if !options[:ignore_response], do: GenServer.reply(from, {:error, msg})
    noreply
  end


  defhandleinfo %HTTPotion.AsyncChunk{id: id, chunk: chunk},
  state: {from, async_id, options}, export: false, when: id == async_id do

    if !options[:ignore_response], do: GenServer.reply(from, {:ok, to_string(chunk)})
    noreply
  end


  defhandleinfo %HTTPotion.AsyncEnd{id: id},
  state: {_, async_id, _}, export: false, when: id == async_id do
    new_state nil
  end


  # Stops the server on timeout message
  defhandleinfo :timeout, do: stop_server(:normal)
  defhandleinfo _, do: noreply
end
