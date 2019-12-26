defmodule Martenblog.Activitypub do
  require Logger
  alias Martenblog.APResolver
  alias Martenblog.Entry
  alias Martenblog.Utils
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

  def article(id) do
    eContent = Entry.entry(id)
    content = case Earmark.as_html(eContent) do
      {:ok, html, _} -> html
      _ -> eContent
    end
    article = %{
      "@context": [
        "https://www.w3.org/ns/activitystreams",
      ],
      type: "Article",
      id: "https://#{@domain}#{Entry.permalink(id)}",
      published: Utils.rfc2616_now,
      # published: DateTime.utc_now |> DateTime.to_iso8601,
      # conversation: "https://#{@domain}/ap/conversation/#{UUID.uuid4}",
      url: "https://#{@domain}#{Entry.date_link(id)}",
      attributedTo: "https://#{@domain}/ap/actor",
      # to: [ # "https://#{@domain}/ap/actor/followers" ],
      to: APResolver.followers,
      cc: [
      ],
      name: Entry.subject(id),
      content: content
    }
    article
  end

  def note(text, ib) do
    inbox = if is_nil(ib) do
      "https://#{@domain}/ap/actor/followers"
    else
      ib
    end
    %{
      "@context": "https://www.w3.org/ns/activitystreams",
      type: "Note",
      id: "https://#{@domain}/ap/note/#{UUID.uuid4}",
      published: Utils.rfc2616_now,
      # published: DateTime.utc_now |> DateTime.to_iso8601,
      attributedTo: "https://#{@domain}/ap/actor",
      to: [
        inbox
        # "https://www.w3.org/ns/activitystreams#Public"
      ],
      cc: [
        "https://#{@domain}/ap/actor/followers"
      ],
      name: "A wildebeest",
      content: text
    }
  end

  def follow_external(url) do
    %{
      "@context": "https://www.w3.org/ns/activitystreams",
      id: "https://#{@domain}/ap/following/#{UUID.uuid4}",
      type: "Follow",
      actor: "https://#{@domain}/ap/actor",
      object: url
    }
  end

  def create_activity(object) do
    uuid = UUID.uuid4
    %{
      "@context": "https://www.w3.org/ns/activitystreams",
      type: "Create",
      id: "https://#{@domain}/ap/#{uuid}",
      published: Utils.rfc2616_now,
      # published: DateTime.utc_now |> DateTime.to_iso8601,
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
      attachment: [
        %{
          name: "Pronouns",
          type: "PropertyValue",
          value: "it"
        }
      ],
      icon: %{
              type: "Image",
              mediaType: "image/png",
              url: "https://#{@domain}/images/gretel-125x125.jpg"
            },
      inbox: "https://#{@domain}/ap/actor/inbox",
      outbox: "https://#{@domain}/ap/actor/outbox",
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

  def remote_actor(uri, make_follower, force) do
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

  def outbox do
    federated_articles = Entry.federated_entry_ids |> Enum.map(&Martenblog.Activitypub.article/1) |> Enum.map(&Martenblog.Activitypub.create_activity/1)
    %{
      "@context": "https://www.w3.org/ns/activitystreams",
      id: "https://#{@domain}/ap/actor/outbox",
      orderedItems: federated_articles,
      totalItems: Entry.count_federated_entries,
      type: "OrderedCollection"
    }
  end

  def accept(obj) do
    to = obj["actor"]
    accept_object = %{
      "@context": "https://www.w3.org/ns/activitystreams",
      id: "https://#{@domain}/ap/accept/#{UUID.uuid4}",
      type: "Accept",
      published: Utils.rfc2616_now,
      # published: DateTime.utc_now |> DateTime.to_iso8601,
      to: [
        to
      ],
      actor: "https://#{@domain}/ap/actor",
      object: Map.delete(obj, "@context")
    }
    Logger.info "outgoing accept object is ---"
    IO.inspect accept_object
    accept_object
  end

  def reject(obj) do
    Map.merge(accept(obj), %{ type: "Reject" })
  end

  def webfinger do
    json = %{
      aliases: [
        "https://#{@domain}/ap/actor"
      ],
      links: [
        %{
          href: "https://#{@domain}/ap/actor",
          rel: "self",
          type: "application/activity+json"
        }
      ],
      subject: "acct:martenblog@#{@domain}"
    }
    json
  end
  
  def sign_and_send(activity, inbox) do
    target_domain = Fuzzyurl.from_string(inbox).hostname
    inbox_fragment = String.replace(inbox, "https://#{target_domain}", "")
    date_str = Utils.rfc2616_now 
    Logger.info "Reading private key..."
    {:ok, priv_key} = File.read("/home/polaris/keys/martenblog.pem")
    Logger.info "priv_key: #{priv_key}"
    string_to_sign = "(request-target): post #{inbox_fragment}\nhost: #{target_domain}\ndate: #{date_str}"
    [ rsa_entry | _ ] = :public_key.pem_decode(priv_key)
    decoded_key = :public_key.pem_entry_decode(rsa_entry)
    sign_me = :public_key.sign(string_to_sign, :sha256, decoded_key)
    signature = :base64.encode(sign_me)
    sig_header = "keyId=\"https://#{@domain}/ap/actor#main-key\",headers=\"(request-target) host date\",algorithm=\"rsa-sha256\",signature=\"#{signature}\""
    case Poison.encode activity do
      {:ok, json_activity} -> 
        Logger.info "sign_and_send -> activity: #{json_activity}"
        Logger.info "string_to_sign: #{string_to_sign}"
        Logger.info "signature header: #{sig_header}"
        Logger.info "date_str: #{date_str}"
        case :hackney.post(inbox, [
            Host: target_domain, 
            Date: date_str, 
            Signature: sig_header, 
            "Content-Type": "application/ld+json; profile=\"https://www.w3.org/ns/activitystreams\"",
            Accept: "application/activity+json, application/ld+json" 
          ], json_activity) do
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
      actor = remote_actor(uri, true, false)
      if is_nil(actor) do
        Logger.error("Actor not found")
      else
        # I want to see what happens here!
        {:ok, _, _, res} = sign_and_send(accept(activity), Map.get(actor, "inbox"))
        Logger.info "What comes back from an Accept Activity?"
        IO.inspect :hackney.body(res)
      end 
    end 
  end

  def incoming(%{ "type" => "Undo" } = activity) do
    object = Map.get(activity, "object")
    case Map.get(object, "type") do
      "Follow" -> unfollow(activity)
      "Accept" ->
        Logger.info "incoming Undo Accept activity"
        IO.inspect activity
      t ->
        Logger.error "Unknown type of \"Undo\": #{t}"
    end
  end

  def incoming(%{"type" => "Accept" } = activity) do
    Logger.info "incoming Accept activity"
    IO.inspect activity
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
      type: "Collection",
      id: "https://#{@domain}/ap/actor/followers",
      totalItems: Enum.count(ids),
      items: ids
    }
    Poison.encode! res
  end

  def federate_entry(entry_id, federated_to) do
    para_federar = MapSet.difference(MapSet.new(APResolver.followers), MapSet.new(federated_to)) |> MapSet.to_list
    res = if Enum.count(para_federar) > 0 do
      IO.puts "Federating"
      IO.puts "Entry #{entry_id} - #{Entry.subject(entry_id)}"
      IO.puts Poison.encode!(para_federar)
      para_federar |> APResolver.inboxes |> Enum.each(fn inbox ->
        article(entry_id) |> create_activity |> sign_and_send(inbox)
      end)
      Entry.mark_federated(entry_id, para_federar)
      para_federar
    else
      IO.puts "No one to federate to"
      []
    end
  end

  # This needs to be a create activity
  def federate_to_followers(activity) do
    APResolver.followers |> APResolver.inboxes |> Enum.each(fn inbox ->
      activity |> sign_and_send(inbox)
    end)
  end
end

