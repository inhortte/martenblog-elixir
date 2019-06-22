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
    inbox: "https://flavigula.net/flavigula/inbox",
    outbox: "https://flavigula.net/flavigula/outbox",
    followers: "https://flavigula.net/flavigula/followers",
    following: "https://flavigula.net/flavigula/following",
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
end
