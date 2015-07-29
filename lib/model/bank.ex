defmodule FinTex.Model.Bank do

  require Record

  Record.defrecordp :bank, __MODULE__,
    blz: nil,
    url: nil,
    version: nil

  @type blz :: binary
  @type url :: binary
  @type version :: binary

  @type t :: {__MODULE__, blz, url, version}

  @spec new(blz, url, version) :: t
  def new(blz, url, version) when is_binary(blz) and is_binary(url) and is_binary(version) do
    cond do
      !Regex.match?(~r/^\d{8}$/, blz)
        -> {:error, "\"blz\" must be an exact 8 digits binary."}
      match? {:error, _}, validate_uri(url)
        -> validate_uri(url)
      version != "220" && version != "300"
        -> {:error, "\"version\" must be one of the following values: \"220\", \"300\""}
      :else
        -> bank(blz: blz, url: url, version: version)
    end
  end

  @doc false
  @spec blz(t) :: binary
  def blz(bank(blz: blz)) do
    blz
  end


  @doc false
  @spec url(t) :: binary
  def url(bank(url: url)) do
    url
  end


  @doc false
  @spec version(t) :: binary
  def version(bank(version: version)) do
    version
  end


  defp validate_uri(url) do
    case URI.parse(url) do
      %URI{scheme: scheme} when scheme != "https"
        -> {:error, "scheme of URL \"#{url}\" must be HTTPS."}
      %URI{host: nil}
        -> {:error, "host of URL \"#{url}\" is invalid."}
      %URI{host: host}
        -> host |> to_char_list |> :inet.gethostbyname
    end
  end 
end
