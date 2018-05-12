defmodule Martenblog.Router do
  use Plug.Router
  require Logger

  plug Plug.Logger

  plug CORSPlug, origin: ["*"]
  
  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json, Absinthe.Plug.Parser],
    json_decoder: Poison

  plug Plug.Static,
    at: "/",
    from: "./web/public",
    # from: {:martenblog, "./web/public"},
    only: ~w(css js images vendor favicon.ico)

  plug :match
  plug :dispatch

  forward "/gql", to: Absinthe.Plug,
    schema: Martenblog.Schema

  forward "/giql", to: Absinthe.Plug.GraphiQL,
    init_opts: [
      schema: Martenblog.Schema,
      interface: :playground
    ]

  get "/*_rest" do
    send_file(conn, 200, "./web/public/index.html")
  end

  match _ do
    send_resp(conn, 404, "thurk?")
  end
end

