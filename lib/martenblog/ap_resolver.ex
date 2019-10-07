defmodule Martenblog.APResolver do
  require Logger

  def find_actor(uri) do
    actor = Mongo.find_one(:mongo, "actor", %{ uri: uri })
    if is_nil(actor) do
      nil
    else
      Map.get(actor, "json")
    end
  end

  def add_actor(uri, json) do
    Mongo.insert_one(:mongo, "actor", %{ uri: uri, json: json })
    json
  end

  def remove_actor(uri) do
    actor = find_actor(uri)
    if !is_nil(actor) do
      Mongo.delete_one(:mongo, "actor", %{ uri: uri })
    end
    actor
  end
end
