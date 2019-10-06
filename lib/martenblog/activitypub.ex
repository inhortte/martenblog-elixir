defmodule Martenblog.Activitypub do
  require Logger
  alias Martenblog.APResolver
  use Application
  @domain Application.get_env(:martenblog, :domain)

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

  def remote_actor(uri) do
    case APResolver.find_actor(uri) do
      false -> 
        case :hackney.get(uri, [ Accept: "application/activity+json" ]) do
          {:ok, 200, _, ref} -> 
            case :hackney.body(ref) do
              {:ok, json} -> 
                json = APResolver.add_actor(uri, json)
                Poison.decode! json
              error -> error
            end
          error -> error
        end
      json ->
        case Poison.decode(json) do
          {:ok, obj} -> obj
          _ -> false
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

  def webfinger do
    {:ok, json} = File.read("./etc/webfinger.json")
    json
  end
  
  def sign_and_send(activity, inbox) do
    target_domain = Fuzzyurl.from_string(inbox).hostname
    inbox_fragment = String.replace(inbox, "https://#{target_domain}", "")
    date_str = DateTime.to_string(DateTime.utc_now)
    Logger.info "Reading private key..."
    {:ok, priv_key} = File.read("./etc/private.pem")
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

  def incoming(%{ type: "Follow", object: "https://#{@domain}/ap/actor" } = activity) do
    Logger.info activity
    
    { :success,  accept(activity) }
  end
  def incoming(activity) do
    Logger.info "problems: #{activity}"
    { :error, "Problems: #{activity.type}" }
  end
end

