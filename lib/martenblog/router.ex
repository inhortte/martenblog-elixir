defmodule Martenblog.Router do
  use Plug.Router
  alias Martenblog.Utils
  alias Martenblog.Entry
  alias Martenblog.Topic
  alias Martenblog.BlogResolver
  require Logger

  plug Plug.Logger
  plug CORSPlug, origin: ["*"]
  plug :match
  plug Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  plug :dispatch

  get "/entry/:id" do
    inter_conn = conn |> put_resp_content_type("application/json")
    case Integer.parse(conn.params["id"]) do
      {id, _} -> 
	send_resp(inter_conn, 200, Entry.get_entry_by_id(id) |> Utils.to_json)
      :error ->
	send_resp(inter_conn, 200, Entry.get_entry_by_id(1) |> Utils.to_json)
    end
  end

  get "/topics" do
    conn |> put_resp_content_type("application/json") |> send_resp(200, %{:topics => Topic.all} |> Utils.to_json)
  end
  
  post "/topics" do
    IO.inspect conn.body_params
    res = case conn.body_params do
	    %{"topic_ids" => topic_ids} -> Topic.topic_ids_to_topics_string(topic_ids)
	    _ -> []
	  end
    conn |> put_resp_content_type("application/json") |> send_resp(200, %{:topics => res} |> Utils.to_json)
  end

  post "/pcount" do
    conn |> put_resp_content_type("application/json") |>
      send_resp(200, %{:pcount => BlogResolver.p_count(conn.body_params["topic_ids"], conn.body_params["search"])} |>
			Utils.to_json)
  end
  
  plug Plug.Static,
    at: "/",
    from: "./web/public",
    # from: {:martenblog, "./web/public"},
    only: ~w(css js images vendor favicon.ico)


  get "/*_rest" do
    send_file(conn, 200, "./web/public/index.html")
  end

  match _ do
    send_resp(conn, 404, "thurk?")
  end
end

