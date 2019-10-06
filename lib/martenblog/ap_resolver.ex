defmodule Martenblog.APResolver do
  require Logger

  def find_actor(uri) do
    actor = Mongo.find_one(:mongo, "actor", %{ uri: uri })
    if is_nil(actor) do
      false
    else
      Map.get(actor, "json")
    end
  end

  def add_actor(uri, json) do
    Mongo.insert_one(:mongo, "actor", %{ uri: uri, json: json })
    json
  end
end
