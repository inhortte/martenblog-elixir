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

  def add_actor(uri, json, make_follower \\ false) do
    Mongo.insert_one(:mongo, "actor", %{ uri: uri, json: json, follower: make_follower })
    json
  end

  def remove_actor(uri) do
    actor_json = find_actor(uri)
    if !is_nil(actor_json) do
      Mongo.delete_one(:mongo, "actor", %{ uri: uri })
    end
    actor_json
  end

  def follow(uri) do
    actor_json = find_actor(uri)
    if !is_nil(actor_json) do
      Mongo.update_one(:mongo, "actor", %{ uri: uri }, %{ "$set": %{ follower: true }})
      actor_json
    else
      nil
    end
  end

  def unfollow(uri) do
    actor_json = find_actor(uri)
    if !is_nil(actor_json) do
      Mongo.update_one(:mongo, "actor", %{ uri: uri }, %{ "$set": %{ follower: false }})
      actor_json
    else
      nil
    end
  end

  def followers do
    Mongo.find(:mongo, "actor", %{ follower: true }) |> Enum.map(fn actor -> Map.get(actor, "json") |> Map.get("id") end)
  end
end
