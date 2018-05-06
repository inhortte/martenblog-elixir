defmodule Martenblog.BlogResolver do
  require Logger

  defp topic_ids_arr(topic_ids) do
    %{"$or": Enum.map(topic_ids, fn(id) -> %{"topic_ids": %{"$elemMatch": %{"$eq": id}}} end)}
  end

  defp search_opts(search) do
    %{"$or": [%{"subject": %{"$regex": String.trim(search), "$options": "i"}},
	      %{"entry": %{"$regex": String.trim(search), "$options": "i"}}]}
  end

  defp mk_find_opts(topic_ids \\ [], search \\ nil) do
    cond do
      Enum.empty?(topic_ids) and is_nil(search) ->
	%{}
      !Enum.empty?(topic_ids) and is_nil(search) ->
	topic_ids_arr(topic_ids)
      Enum.empty?(topic_ids) and !is_nil(search) ->
	search_opts(search)
      true ->
	%{"$and": [topic_ids_arr(topic_ids), search_opts(search)]}
    end
  end
  
  def all_topics(_root, _args, _info) do
    topics = Mongo.find(:mongo, "topic", %{})
    Logger.info Enum.count(topics)
    {:ok, Enum.to_list(topics)}
  end

  def last_topic(_root, _args, _info) do
    topic = Mongo.find_one(:mongo, "topic", %{})
    {:ok, topic}
  end

  def entries_paged(_root, args, _info) do
    page = args.page || 1
    limit = args.limit || 11
    topic_ids = args.topic_ids || []
    search = args.search || nil
    entries = Enum.to_list(Mongo.find(:mongo, "entry", mk_find_opts(topic_ids, search), skip: (page - 1) * 11, sort: %{"created_at": -1}, limit: limit))
    # c = Enum.count(entries)
    {:ok, entries}
  end

  def entry_by_id(_root, %{id: id}, _info) do
    entry = Mongo.find_one(:mongo, "entry", %{_id: id})
    {:ok, entry}
  end

  def topics_by_ids(_root, %{ids: ids}, _info) do
    topics = Enum.map(ids, fn(id) -> Mongo.find_one(:mongo, "topic", %{_id: id}) end)
    {:ok, topics}
  end
end
