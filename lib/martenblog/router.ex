defmodule Martenblog.Router do
  use Plug.Router
  alias Martenblog.{Utils, Entry, Topic, Http, BlogResolver, PoemResolver, Activitypub, AuthResolver, Twtxt}
  require Logger
  @domain Application.get_env(:martenblog, :domain)
  @twtxt_avatar "/home/polaris/arch-my-hive/twtxt/avatar.png"
  @twtxt_file "/home/polaris/arch-my-hive/twtxt/twtxt.txt"

  plug Plug.Logger
  # plug Plug.SSL
  plug CORSPlug, origin: ["*"]
  plug Plug.Static,
    at: "/",
    # cache_control_for_etags: "no-cache",
    from: "./web/public"
    # from: {:martenblog, "./web/public"},
    # only_matching: ["index.html", "css", "js", "js/bundle", "images", "blog"]
    # only: ~w(css js images vendor favicon.ico)

  plug :match
  plug Plug.Parsers,
    parsers: [:json, :multipart, :urlencoded],
    pass: ["application/json", "multipart/form-data", "text/*", "application/x-www-form-urlencoded"],
    json_decoder: Poison
  plug :dispatch


  get "/entry/page/:page" do
    inter_conn = conn |> put_resp_content_type("application/json")
    case Integer.parse(conn.params["page"]) do
      {page, _} ->
	send_resp(inter_conn, 200, BlogResolver.entries_paged(%{page: page}) |> Utils.to_json)
      :error ->
	send_resp(inter_conn, 200, BlogResolver.entries_paged(%{page: 1}) |> Utils.to_json)
    end
  end

  get "/entry/by-date/:y/:m/:d" do
    inter_conn = conn |> put_resp_content_type("application/json")
    {y, _} = if Map.has_key?(conn.params, "y"), do: Integer.parse(conn.params["y"]), else: {nil, ""}
    {m, _} = if Map.has_key?(conn.params, "m"), do: Integer.parse(conn.params["m"]), else: {nil, ""}
    {d, _} = if Map.has_key?(conn.params, "d"), do: Integer.parse(conn.params["d"]), else: {nil, ""}
    send_resp(inter_conn, 200, BlogResolver.entries_by_date(%{ y: y, m: m, d: d }) |> Utils.to_json)
  end

  get "/alrededores/:ts" do
    inter_conn = conn |> put_resp_content_type("application/json")
    case Integer.parse(conn.params["ts"]) do
      { ts, _ } ->
	send_resp(inter_conn, 200, BlogResolver.alrededores(ts) |> Utils.to_json)
      :error ->
	send_resp(inter_conn, 200, [nil, nil] |> Utils.to_json)
    end
  end

  get "/entry/:id" do
    inter_conn = conn |> put_resp_content_type("application/json")
    case Integer.parse(conn.params["id"]) do
      {id, _} -> 
	send_resp(inter_conn, 200, Entry.get_entry_by_id(id) |> Utils.to_json)
      :error ->
	send_resp(inter_conn, 200, Entry.get_entry_by_id(1) |> Utils.to_json)
    end
  end

  post "/federate" do
    token = Map.get(conn.params, "token")
    entry_id = Map.get(conn.params, "id")
    federated_to = Map.get(conn.params, "federatedTo")
    res = if AuthResolver.verify_token(token) do
      Logger.info "Authorized to federate"
      los_federado = Activitypub.federate_entry(entry_id, federated_to)
      %{ federatedTo: los_federado }
    else
      Logger.info "Not authorized to federate"
      %{ error: "unauthorized" }
    end
    conn |> put_resp_content_type("application/json") |> send_resp(200, res |> Utils.to_json)
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

  post "/blog_search" do
    html = case conn.params do
      %{"term" => term} -> Http.blog_search(term)
      _ -> Http.blog_nothing_found
    end
    conn |> put_resp_content_type("text/html") |> send_resp(200, html)
  end

  get "/poems" do
    {:ok, poems } = PoemResolver.all_poems
    conn |> put_resp_content_type("application/json") |>
      send_resp(200, poems |> Utils.to_json)
  end

  get "/rss" do
    conn |> put_resp_content_type("text/xml") |>
    send_resp(200, Martenblog.Rss.rss)
  end

  get "/atom" do
    conn |> put_resp_content_type("text/xml") |> send_resp(200, Martenblog.Atom.atom)
  end

  get "/twtxt-atom" do
    conn |> put_resp_content_type("text/xml") |> send_resp(200, Martenblog.Atom.twtxts)
  end

  get "/piece-of-shit" do
    pieces_of_shit = File.read!('/home/polaris/various-leprosies/draining-the-pond/piece-of-shit.txt') 
                     |> String.split(~r{\n}) 
                     |> Enum.map(&String.trim/1) 
                     |> Enum.filter(fn s -> String.length(s) > 0 end)
                     |> Enum.shuffle
    conn |> put_resp_content_type("application/json") |> send_resp(200, pieces_of_shit |> Utils.to_json)
  end

  get "/high-voltage-power-supply" do
    pieces_of_shit = File.read!('/home/polaris/various-leprosies/draining-the-pond/HIGH.VOLTAGE.POWER.SUPPLY') 
                     |> String.split(~r{\n}) 
                     |> Enum.map(&String.trim/1) 
                     |> Enum.filter(fn s -> String.length(s) > 0 end)
                     |> Enum.shuffle
    conn |> put_resp_content_type("application/json") |> send_resp(200, pieces_of_shit |> Utils.to_json)
  end

  get "/lakife-vocabulary" do
    conn |> put_resp_content_type("application/json") |>
    send_resp(
      200,
      case Postgrex.start_link(database: "lakife", username: "polaris") do
      # case Postgrex.child_spec([]) do
        {:ok, pid} -> 
          Postgrex.query!(pid, "select * from vocabulary", [])
        # %{id: pid} -> Postgrex.query!(pid, "select * from vocabulary", [])
        _ -> 
          Logger.info("Vocabulary query didn't run, vole")
          %{rows: []}
      end |> Utils.to_json
    )
  end

  get "/lakife-phrases" do
    conn |> put_resp_content_type("application/json") |>
    send_resp(
      200,
      case Postgrex.start_link(database: "lakife", username: "polaris") do
        {:ok, pid} -> Postgrex.query!(pid, "select * from phrases", [])
        _ -> %{rows: []}
      end |> Utils.to_json
    )
  end

  get "/lakife-grammar" do
    conn |> put_resp_content_type("text/plain") |>
    send_resp(
      200,
      File.read!("/home/polaris/various-leprosies/draining-the-pond/lakife-grammar.md")
    )
  end

  get "/lakife-mihupola" do
    conn |> put_resp_content_type("text/plain") |>
    send_resp(
      200,
      File.read!("/home/polaris/various-leprosies/draining-the-pond/lakife-mihupola.md")
    )
  end

  get "/twtxt/avatar.png" do
    case File.exists?(@twtxt_avatar) do
      true -> conn |> put_resp_content_type("text/plain") |> send_resp(200, File.read!(@twtxt_avatar))
      false -> conn |> send_resp(404, "Nulu qotziukon xaj, tipju.")
    end
  end
  
  get "/twtxt/twtxt.txt" do
    case File.exists?(@twtxt_file) do
      true -> conn |> put_resp_content_type("text/plain") |> send_resp(200, File.read!(@twtxt_file))
      false -> conn |> send_resp(404, "Nulu qotziukon xaj, tipju.")
    end
  end

  get "/twtxt" do
    case Twtxt.read_twtxt_file(nil) do
      {:ok, media_dormida} ->
        conn |> send_resp(200, media_dormida)
      {:error, reason} ->
        conn |> send_resp(200, reason)
    end
  end

  get "/twtxt-search" do
    conn.query_string |> Utils.twtxt_query |>
      (fn prefix ->
        conn |> send_resp(200, prefix)
      end).()
  end

  # Activitypub leper
  get "/.well-known/webfinger" do
    conn |> put_resp_content_type("application/json") |>
      send_resp(200, Poison.encode! Activitypub.webfinger)
  end

  get "/.well-known/host-meta" do
    xml = XmlBuilder.document([
      XmlBuilder.element(:XRD, %{xmlns: "http://docs.oasis-open.org/ns/xri/xrd-1.0"}, [
        XmlBuilder.element(:Link, %{
          rel: "lrdd",
          type: "application/xrd+xml",
          template: "https://#{@domain}/.well-known/webfinger?resource={uri}"
        })
      ])
    ]) |> XmlBuilder.generate
    conn |> put_resp_content_type("application/xrd+xml") |>
      send_resp(200, xml)
  end

  get "/.well-known/nodeinfo" do
    json = %{
      links: [
        %{
          href: "https://#{@domain}/.well-known/nodeinfo/2.0.json",
          rel: "https://nodeinfo.diaspora.software/ns/schema/2.0"
        },
        %{
          href: "https://#{@domain}/.well-known/nodeinfo/2.1.json",
          rel: "https://nodeinfo.diaspora.software/ns/schema/2.1"
        }
      ]
    }
    conn |> put_resp_content_type("application/json") |> send_resp(200, Poison.encode! json)
  end
  get "/.well-known/nodeinfo/2.0.json" do
    conn |> put_resp_content_type("application/json") |> send_resp(200, Poison.encode!(Activitypub.nodeinfo("2.0")))
  end
  get "/.well-known/nodeinfo/2.1.json" do
    conn |> put_resp_content_type("application/json") |> send_resp(200, Poison.encode!(Activitypub.nodeinfo("2.1")))
  end

  get "/ap/actor" do
    conn |> put_resp_content_type("application/activity+json") |>
      send_resp(200, Activitypub.local_actor)
  end

  get "/ap/actor/outbox" do
    conn |> put_resp_content_type("application/activity+json") |>
      send_resp(200, Poison.encode! Activitypub.outbox)
  end

  post "/ap/actor/inbox" do
    # String.split(leper, ",") |> Enum.map(fn s -> String.split(s, "=", parts: 2) end) |> Enum.map(fn l -> {String.to_atom(List.first(l)), String.replace(List.last(l), ~r/\A"/, "") |> String.replace(~r/"\z/, "")} end)
    IO.puts "INCOMING HEADERS"
    IO.inspect conn.req_headers
    IO.puts "INCOMING BODY PARAMS"
    IO.inspect conn.body_params
    conn.body_params |> Activitypub.incoming
    send_resp(conn, 200, "")
    # halt(conn)
    # conn.body_params |> Activitypub.incoming |> (fn({status, message}) ->
    # case status do
    #   :success -> send_resp(conn, 200, message)
    #    _ -> send_resp(conn, 500, message)
    #  end
    #end).()
  end

  get "/ap/actor/followers" do
    conn |> put_resp_content_type("application/activity+json") |>
      send_resp(200, Activitypub.followers)
  end

  # Authentication
  post "/login" do
    IO.inspect conn.body_params
    res = if AuthResolver.verify_password(Map.get(conn.body_params, "heslo")) do
      token = AuthResolver.new_token
      %{ token: token }
    else
      %{ error: "invalid thurk" }
    end
    conn |> put_resp_content_type("application/json") |>
      send_resp(200, Poison.encode! res)
  end

  post "/logout" do
    IO.inspect conn.body_params
    AuthResolver.expire_token(Map.get(conn.body_params, "token"))
    conn |> send_resp(200, Poison.encode! %{ success: true })
  end

  get "/" do
    send_file(conn, 200, "./web/public/index.html")
  end
  # get "/*_rest" do
    # send_file(conn, 200, "./web/public/index.html")
  # end

  match _ do
    send_resp(conn, 404, "Nulu qotziukon xaj, tipju.")
  end
end

