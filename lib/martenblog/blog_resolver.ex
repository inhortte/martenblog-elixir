defmodule Martenblog.BlogResolver do
  require Logger

  defp topic_ids_arr(topic_ids) do
    %{"$or": Enum.map(topic_ids, fn(id) -> %{"topic_ids": %{"$elemMatch": %{"$eq": id}}} end)}
  end

  defp search_opts(search) do
    %{"$or": [%{"subject": %{"$regex": String.trim(search), "$options": "i"}},
	      %{"entry": %{"$regex": String.trim(search), "$options": "i"}}]}
  end

  def mk_find_opts(topic_ids \\ [], search \\ nil) do
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
    topics_ = Mongo.find(:mongo, "topic", %{}) |> Enum.to_list
    IO.inspect topics_
    topics =  topics_ |> Enum.map(fn(t) -> Map.merge(t, %{"count" => Enum.count(Map.get(t, "entry_ids"))}) end)    
    {:ok, topics}
  end

  def last_topic(_root, _args, _info) do
    topic = Mongo.find_one(:mongo, "topic", %{})
    {:ok, topic}
  end

  def normalise_topic_id(topic_id) do
    if is_nil(topic_id) do
      nil
    else
      case Integer.parse(topic_id) do
	:error ->
	  nil
	{t_id, _} ->
	  t_id
      end
    end
  end

  def p_count(_root, args, _info) do
    topic_ids = args.topic_ids && (
      args.topic_ids |> Enum.map(&normalise_topic_id/1) |> Enum.reject(&is_nil/1)
    ) || []
    search = args.search || nil
    Mongo.count(:mongo, "entry", mk_find_opts(topic_ids, search))
  end

  def add_topics_to_entry(entry) do
    topics = Map.get(entry, "topic_ids") |> Enum.map(fn(topic_id) -> Mongo.find_one(:mongo, "topic", %{_id: topic_id}) end)
    Map.merge(entry, %{"topics" => topics})
  end

  def entries_paged(_root, args, _info) do
    page = args.page || 1
    limit = args.limit || 11
    topic_ids = args.topic_ids && (
      args.topic_ids |> Enum.map(&normalise_topic_id/1) |> Enum.reject(&is_nil/1)
    ) || []    
    search = args.search || nil
    entries = Enum.to_list(Mongo.find(:mongo, "entry", mk_find_opts(topic_ids, search), skip: (page - 1) * 11, sort: %{"created_at": -1}, limit: limit))
    entries_with_topics = Enum.map(entries, &add_topics_to_entry/1)
    {:ok, entries_with_topics}
  end

  def entries_by_date(_root, args, _info) do
    y = args.y || 1991
    m = args.m || 10
    d = args.d || 23
    dt = %DateTime{year: y, month: m, day: d, zone_abbr: "UTC",
                    hour: 0, minute: 0, second: 0, microsecond: {0, 0},
                    utc_offset: 0, std_offset: 0, time_zone: "Europe/London"}
    begin_time = DateTime.to_unix(dt) * 1000
    end_time = begin_time + 1000 * 3600 * 24
    Logger.info "year: #{y}, month: #{m}, day: #{d}, begin_time: #{begin_time}, end_time: #{end_time}"
    entries = Enum.to_list(Mongo.find(:mongo, "entry", %{"$and": [
							    %{"created_at": %{"$gte": begin_time}}, %{"created_at": %{"$lte": end_time}}
							  ]}, sort: %{"created_at": -1}));
    entries_with_topics = Enum.map(entries, &add_topics_to_entry/1)    
    {:ok, entries_with_topics}
  end

  def entry_by_id(_root, %{id: id}, _info) do
    entry = Mongo.find_one(:mongo, "entry", %{_id: id})
    {:ok, entry}
  end

  def topics_by_ids(_root, %{ids: ids}, _info) do
    topics = Enum.map(ids, fn(id) -> Mongo.find_one(:mongo, "topic", %{_id: id}) end)
    {:ok, topics}
  end

  def alrededores(_root, %{timestamp: timestamp}, _info) do
    d = DateTime.from_unix!(Kernel.trunc(timestamp / 1000))
    nd = %DateTime{year: d.year, month: d.month, day: d.day, zone_abbr: "UTC", hour: 0, minute: 0, second: 0, microsecond: {0, 0}, utc_offset: 0, std_offset: 0, time_zone: "Europe/London"}
    dayBegins = DateTime.to_unix(nd) * 1000
    dayEnds = dayBegins + 1000 * 3600 * 24 - 1
    prevEntry = Mongo.find(:mongo, "entry", %{"created_at" => %{"$lt": dayBegins}}, sort: %{"created_at": -1}, limit: 1) |> Enum.to_list |> List.first
    nextEntry = Mongo.find(:mongo, "entry", %{"created_at" => %{"$gt": dayEnds}}, sort: %{"created_at": 1}, limit: 1) |> Enum.to_list |> List.first
    prevDate = if is_nil(prevEntry) do
      nil
    else
      Map.get(prevEntry, "created_at")
    end
    nextDate = if is_nil(nextEntry) do
      nil
    else
      Map.get(nextEntry, "created_at")
    end
    {:ok, [prevDate, nextDate]}
  end
end
