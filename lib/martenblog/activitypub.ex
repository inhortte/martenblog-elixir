defmodule Martenblog.Activitypub do
  require Logger

  
end

defmodule Martenblog.Actor do
  defstruct [
    "@context": [
    "https://www.w3.org/ns/activitystreams",
    "https://w3id.org/security/v1"
    ],
    type: "Person",
    id: "https://flavigula.net/flavigula",
    name: "Bobbus Mustelidus",
    preferredUsername: "flavigula",
    summary: "A mustelid",
    inbox: "https://flavigula.net/inbox",
    outbox: "https://flavigula.net/outbox",
    followers: "https://flavigula.net/followers",
    following: "https://flavigula.net/following",
    liked: "https://flavigula.net/flavigula/liked",
    ]

  def flavigula_actor do
    base_actor = %Martenblog.Actor{}
    public_key = %{
      id: "https://flavigula.net/flavigula#main-key",
      owner: "https://flavigula.net/flavigula",
      publicKeyPem: "-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtelgXLbzw5ZU4dCMkE6F
Z1temnUI34XanUUgOTba4Q7bZJnqG1POTKeWLGRtHMjqDtdQBEpmNKBpYKD5odoF
f/MtEXxCcm2BLW+2XnZMqMFWZDaYfLIPLvdCRcS27fQpxjlpQcpx8F3mIgfiUbcm
ptxt6EhHVAMI8h7Y3oFkztwycOMGIj9aHX/SuvPh5U/0X7S6uuq+5141z9+kh89n
vN31bkFQ4EtE6yw0++pI/koN0yX29+8D3OP5qtHrqtSzYQWhCOjKgB8Uk91WVX+y
jhYTTM2hNUCtTrqMp1KFzBcofvWC22cBvfXtYir60W4dn3JOwheZnW5AgwmUNG+L
VQIDAQAB
-----END PUBLIC KEY-----"
    }
    Map.merge(base_actor, %{ :publicKey => public_key })
  end

  def webfinger do
    %{
      subject: "acct:flavigula@flavigula.net",
      links: [
	%{
	  rel: "self",
	  type: "application/activity+json",
	  href: "https://flavigula.net/flavigula"
	}
      ]
    }
  end

  def you_die do
    document = File.read!("etc/you-die.json")
    date = DateTime.to_string(DateTime.utc_now)
    signed_string = "(request-target): post /inbox\nhost: altaica.cloud\ndate: #{date}"
    priv_key = File.read!('etc/private.pem')
    [ decoded_priv_key | _ ] = :public_key.pem_decode(priv_key)
    entry_key = :public_key.pem_entry_decode(decoded_priv_key)
    sign_me = :public_key.sign(signed_string, :sha256, entry_key)
    signature = :base64.encode(sign_me)
    header = "keyId=\"https://flavigula.net/flavigula\",headers=\"(request-target) host date\",signature=\"#{signature}\""

    # headers = %{ "Host" => "altaica.cloud", "Date" => date, "Signature" => header }
    headers = %{ "Host" => "altaica.cloud", "Date" => date, "Signature" => header }
  end
end
