defmodule Martenblog.Router do
  use Plug.Router
  require Logger
  
  plug Plug.Logger
  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json, Absinthe.Plug.Parser],
    json_decoder: Poison

  plug Plug.Static,
    at: "/public",
    from: :martenblog

  plug :match
  plug :dispatch
  #  plug :not_found
  plug Martenblog.Nigger, [name: "Christián"]

  get "/" do
    conn |> send_resp(200, "you die!")
  end

  get "/thurk" do
    conn |> send_resp(200, "death!")
  end

  forward "/gql", to: Absinthe.Plug,
    schema: Martenblog.Schema

  forward "/giql", to: Absinthe.Plug.GraphiQL,
    init_opts: [
      schema: Martenblog.Schema,
      interface: :playground
    ]


#  def not_found(conn, _) do
#    send_resp(conn, 404, "not found")
#  end

#  def start_link do
#    Plug.Adapters.Cowboy.http(Martenblog.Router, [])
#  end
end

