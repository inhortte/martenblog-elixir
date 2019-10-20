defmodule Martenblog.Activitypub do
  require Logger
  alias Martenblog.APResolver
  alias Martenblog.Entry
  use Application
  @domain Application.get_env(:martenblog, :domain)


  def nodeinfo(ver) do
    json = %{
      version: ver,
      protocols: ["activitypub"],
      services: %{
        inbound: [],
        outbound: []
      },
      openRegistrations: false,
      usage: %{
        users: %{
          total: 1,
          activeHalfyear: 1,
          activeMonth: 1
        },
        localPosts: Entry.entry_count
      }
    }
    software = Map.merge(%{
      name: "Martenblog",
      version: "1.0.0"
    }, if String.equivalent?(ver, "2.1") do
      %{ repository: "https://github.com/inhortte/martenblog-elixir.git" }
    else
      %{}
    end)
    Map.merge(json, %{ software: software })
  end

  def article(id, _inbox) do
    article = %{
      "@context": [
        "https://www.w3.org/ns/activitystreams",
      ],
      type: "Article",
      id: "https://#{@domain}#{Entry.permalink(id)}",
      published: Entry.published(id),
      inReplyTo: nil,
      conversation: "https://#{@domain}/ap/conversation/#{UUID.uuid4}",
      url: "https://#{@domain}#{Entry.date_link(id)}",
      attributedTo: "https://#{@domain}/ap/actor",
      to: [
        "https://www.w3.org/ns/activitystreams#Public"
      ],
      cc: [
        "https://#{@domain}/ap/actor/followers"
      ],
      name: Entry.subject(id),
      content: Entry.entry(id)
    }
    article
  end

  def create_activity(object) do
    uuid = UUID.uuid4
    %{
      "@context": [
        "https://www.w3.org/ns/activitystreams"
      ],
      type: "Create",
      id: "https://#{@domain}/ap/#{uuid}",
      actor: "https://#{@domain}/ap/actor",
      to: object[:to],
      cc: object[:cc],
      object: object
    }
  end

  def local_actor do
    {:ok, pub_key} = File.read("./etc/public.pem");
    # Logger.info "pub_key: #{pub_key}"
    actor = %{
      "@context": [
              "https://www.w3.org/ns/activitystreams",
              "https://w3id.org/security/v1"
            ],
      type: "Person",
      id: "https://#{@domain}/ap/actor",
      preferredUsername: "martenblog",
      name: "Martenblog",
      icon: %{
              type: "Image",
              mediaType: "image/png",
              url: "https://#{@domain}/images/gretel-125x125.jpg"
            },
      inbox: "https://#{@domain}/ap/inbox",
      followers: "https://#{@domain}/ap/actor/followers",
      publicKey: %{
              id: "https://#{@domain}/ap/actor#main-key",
              owner: "https://#{@domain}/ap/actor",
              publicKeyPem: pub_key
            }
    }
    {:ok, actor_json} = Poison.encode actor
    actor_json
  end

  def fetch_actor(uri) do
    res = case :hackney.get(uri, [ Accept: "application/activity+json" ]) do
      {:ok, 200, _, ref} -> :hackney.body(ref)
      error -> error
    end
    case res do
      {:ok, body} ->
        case Poison.decode body do
          {:ok, json} -> json
          error ->
            Logger.error "Poison error: json was not returned (wrong actor url)"
            error
        end
      error -> 
        Logger.error "Hackney error: #{error}"
        error
    end
  end

  def remote_actor(uri, make_follower \\ false, force \\ false) do
    actor = APResolver.find_actor(uri)
    if force or is_nil(actor) do
      case fetch_actor(uri) do
        {:error, _} -> nil
        json -> APResolver.add_actor uri, json, make_follower
      end
    else
        # Poison.decode! actor
      Logger.info "Cached in mongo"
      if make_follower do
        APResolver.follow(uri);
      else
        actor
      end
    end
  end

  def accept(obj) do
    accept_object = %{
      "@context": "https://www.w3.org/ns/activitystreams",
      id: "https://#{@domain}/ap/#{UUID.uuid4}",
      type: "Accept",
      actor: "https://#{@domain}/ap/actor",
      object: obj
    }
    accept_object
  end

  def reject(obj) do
    Map.merge(accept(obj), %{ type: "Reject" })
  end

  def webfinger do
    {:ok, json} = File.read("./etc/webfinger.json")
    json
  end
  
  def sign_and_send(activity, inbox) do
    target_domain = Fuzzyurl.from_string(inbox).hostname
    inbox_fragment = String.replace(inbox, "https://#{target_domain}", "")
    date_str = DateTime.to_string(DateTime.utc_now)
    Logger.info "Reading private key..."
    {:ok, priv_key} = File.read("/home/polaris/keys/martenblog.pem")
    Logger.info "priv_key: #{priv_key}"
    string_to_sign = "(request-target): post #{inbox_fragment}\nhost: #{target_domain}\ndate: #{date_str}"
    [ rsa_entry | _ ] = :public_key.pem_decode(priv_key)
    decoded_key = :public_key.pem_entry_decode(rsa_entry)
    sign_me = :public_key.sign(string_to_sign, :sha256, decoded_key)
    signature = :base64.encode(sign_me)
    sig_header = "keyId=\"https://#{@domain}/ap/actor#main-key\",headers=\"(request-target) host date\",signature=\"#{signature}\""
    case Poison.encode activity do
      {:ok, json_activity} -> 
        Logger.info "activity: #{json_activity}"
        Logger.info "string_to_sign: #{string_to_sign}"
        Logger.info "signature header: #{sig_header}"
        case :hackney.post(inbox, [ Host: target_domain, Date: date_str, Signature: sig_header, Accept: "application/activity+json, application/json" ],
          json_activity) do
          {:ok, res} -> res
          error -> error
        end
      error -> error
    end 
  end

  def unfollow(activity) do
    Logger.info("Undo Follow")
    uri = Map.get(activity, "actor")
    Logger.info "uri: #{uri}"
    if is_nil(uri) do
      Logger.error "Activity doesn't have \"actor\""
    else
      actor = APResolver.unfollow(uri)
      if is_nil(actor) do
        Logger.error("Actor not found")
      else
        sign_and_send(accept(activity), Map.get(actor, "inbox"))
      end 
    end 
  end

  def incoming(%{ "type" => "Follow", "object" => "https://#{@domain}/ap/actor" } = activity) do
    Logger.info "Follow"
    uri = Map.get(activity, "actor")
    Logger.info "uri: #{uri}"
    if is_nil(uri) do
      Logger.error "Activity doesn't have \"actor\""
    else
      actor = remote_actor(uri, true)
      if is_nil(actor) do
        Logger.error("Actor not found")
      else
        sign_and_send(accept(activity), Map.get(actor, "inbox"))
      end 
    end 
  end

  def incoming(%{ "type" => "Undo" } = activity) do
    object = Map.get(activity, "object")
    case Map.get(object, "type") do
      "Follow" -> unfollow(activity)
      t ->
        Logger.error "Unknown type of \"Undo\": #{t}"
    end
  end

  def incoming(activity) do
    Logger.info "problems: unknown activity"
    { :error, "Problems: #{Map.get(activity, "type")}" }
  end

  def followers do
    ids = APResolver.followers
    res = %{
      "@context": [
        "https://www.w3.org/ns/activitystreams"
      ],
      type: "OrderedCollection",
      id: "https://#{@domain}/ap/actor/followers",
      totalItems: Enum.count(ids),
      items: ids
    }
    Poison.encode! res
  end

  def federate(entry_id, federated_to) do
    para_federar = MapSet.difference(MapSet.new(APResolver.followers), MapSet.new(federated_to)) |> MapSet.to_list
    res = if Enum.count(para_federar) > 0 do
      IO.puts "Federating"
      IO.puts "Entry #{entry_id} - #{Entry.subject(entry_id)}"
      IO.puts Poison.encode!(para_federar)
      para_federar |> APResolver.inboxes |> Enum.each(fn inbox ->
        article(entry_id, inbox) |> sign_and_send(inbox)
      end)
    else
      IO.puts "No one to federate to"
    end
  end
end

