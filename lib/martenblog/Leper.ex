defmodule Leper do
  def post(protocol, host, port, path, headers_map) do
    {:ok, conn} = Mint.HTTP.connect(_scheme = protocol, _host = host, _port = port)
    headers = List.foldl(Map.keys(headers_map), [], fn (key, acc) -> [ {key, Map.get(headers_map, key)} | acc ] end)
    IO.inspect headers
    {:ok, conn, request_ref} = Mint.HTTP.request(conn, "POST", path, headers)
    {conn, request_ref}
  end
end
