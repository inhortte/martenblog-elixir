defmodule Martenblog.Topic do
  require Logger
  alias Martenblog.Utils

  defstruct id: 0, topic: "", entry_ids: [], created_at: DateTime.utc_now
  @oddities %{:id => "_id"}

  def to_mongoable(topic) do
    Map.keys(topic) |> Enum.reduce(%{}, fn(key, acc) ->
      cond do
	key == :__struct__ ->
	  acc
	Enum.member?(Map.keys(@oddities), key) ->
	  Map.merge(acc, %{@oddities[key] => Map.get(topic, key)})
	true -> 
	  Map.merge(acc, %{Atom.to_string(key) => Map.get(topic, key)})
      end
    end)
  end

  def ensure_created_at(topic) do
    if is_nil(topic[:created_at]) do
      Map.merge(topic, %{created_at: nil})
    else
      topic
    end
  end

  def to_topic_struct(map) do
    Kernel.struct(%Martenblog.Topic{}, map)
  end

  def all() do
    Mongo.find(:mongo, "topic", %{}) |> Enum.map(fn(topic) ->
      Utils.normalise_keys(topic) |> ensure_created_at |> to_topic_struct
    end)
  end

  def topics_by_ids(ids) do
    topics = Enum.map(ids, fn(id) -> Mongo.find_one(:mongo, "topic", %{_id: id}) end)
    topics
  end

  def next_topic_id() do
    Mongo.find(:mongo, "topic", %{}, sort: %{"_id" => -1}, limit: 1) |> Enum.to_list |> List.first |>
    (fn first_topic -> 
      # IO.inspect first_topic
      first_topic || %{"_id" => 0}
    end).() |>
    Map.get("_id") |> 
    (fn id -> id + 1 end).()
  end  

  def new_topic(topic_string) do
    topic = %Martenblog.Topic{}
    case Mongo.insert_one(:mongo, "topic", to_mongoable(%{topic | topic: topic_string, id: next_topic_id()})) do
      {:ok, %Mongo.InsertOneResult{inserted_id: new_id}} ->
	new_id
      _ -> 0
    end
  end

  def add_entry_id_to_topic(topic_id, entry_id) do
    case Mongo.update_one(:mongo, "topic", %{"_id" => topic_id}, %{"$addToSet": %{entry_ids: entry_id}}) do
      {:ok, _} ->
	Logger.info "added entry #{entry_id} to topic #{topic_id}"
      _ ->
	Logger.info "could not add entry #{entry_id} to topic #{topic_id}"
    end
  end

  def topic_ids_to_topics_string(topic_ids) do
    Mongo.find(:mongo, "topic", %{"_id" => %{"$in" => topic_ids}}) |> Enum.map(fn(topic) -> topic["topic"] end)
  end
end

defmodule Martenblog.Entry do
  require Logger
  alias Martenblog.Topic
  alias Martenblog.Utils
  alias Martenblog.APResolver

  @id_re ~r/^_id:\s+(\d+)\s*$/
  @subject_re ~r/^[Ss]ubject:\s+(.+)$/
  @date_re ~r/^[Dd]ate:\s+(\d+)\s*$/
  @topic_re ~r/^[Tt]opics?:\s+(.+)$/

  @header_res [id: @id_re, subject: @subject_re, created_at: @date_re]

  defstruct id: 0, created_at: 0, entry: "", subject: "", topic_ids: [], user_id: 1, federated_to: [], federated: false, federated_ts: nil
  @oddities %{:id => "_id"}

  def get_entry_by_id(id) do
    entry = Mongo.find_one(:mongo, "entry", %{"_id" => id}) |> Utils.normalise_keys
    Kernel.struct(%Martenblog.Entry{}, entry)
  end

  def get_entries_by_page(page) do
    entries = Mongo.find(:mongo, "entry", %{}, skip: (page - 1) * 11, limit: 11, sort: %{created_at: -1}) |> Enum.to_list
    Enum.map(entries, fn e -> Kernel.struct(%Martenblog.Entry{}, e |> Utils.normalise_keys) end)
  end

  def format_mb_date(dt) do
    year = dt.year
    month = if dt.month < 10, do: "0#{dt.month}", else: "#{dt.month}"
    day = if dt.day < 10, do: "0#{dt.day}", else: "#{dt.day}"
    hour = if dt.hour < 10, do: "0#{dt.hour}", else: "#{dt.hour}"
    minute = if dt.minute < 10, do: "0#{dt.minute}", else: "#{dt.minute}"
    "#{year}#{month}#{day}#{hour}#{minute}"
  end

  def make_mb_timestamp(ts) do
    dt = case DateTime.from_unix(ts) do
	   {:error, _} ->
	     case DateTime.from_unix(trunc(ts / 1000)) do
	       {:error, _} ->
		 DateTime.utc_now
	       {:ok, dt} ->
		 format_mb_date(dt)
	     end
	   {:ok, dt} ->
	     format_mb_date(dt)
	 end
    dt
  end

  def parse_mb_timestamp(mbts) do
    timex_date = case Timex.parse(mbts, "%Y%m%d", :strftime) do
      {:error, _} -> case Timex.parse(mbts, "%Y%m%d%H%M", :strftime) do
        {:error, _} -> Timex.now
        {:ok, timex_time} -> timex_time
      end
      {:ok, timex_time} -> timex_time
    end |> Timex.to_unix |> (fn unix_time -> unix_time * 1000 end).()
  end

  def to_mongoable(entry) do
    Map.keys(entry) |> Enum.reduce(%{}, fn(key, acc) ->
      cond do
	key == :__struct__ ->
	  acc
	Enum.member?(Map.keys(@oddities), key) ->
	  Map.merge(acc, %{@oddities[key] => Map.get(entry, key)})
	true -> 
	  Map.merge(acc, %{Atom.to_string(key) => Map.get(entry, key)})
      end
    end)
  end

  def topic_ids_from_topics_array(ta) do
    topics = Topic.all
    Enum.map(ta, fn(s) ->
      topic_string = String.trim(s) |> String.downcase
      topic = Enum.find(topics, fn(t) -> t.topic == topic_string end)
      if is_nil(topic) do
        Topic.new_topic(topic_string)
      else
        topic.id
      end
    end)
  end

  def topic_ids_from_topics_string(ts) do
    String.split(ts, ~r/\s*,\s*/) |> topic_ids_from_topics_array
  end

  def latest_entry do
    Mongo.find(:mongo, "entry", %{}, sort: %{"created_at" => -1}, limit: 1) |> Enum.to_list |> List.first
  end

  def next_entry_id() do
    Mongo.find(:mongo, "entry", %{}, sort: %{"_id" => -1}, limit: 1) |> Enum.to_list |> List.first |>
    (fn first_entry -> 
      # IO.inspect first_entry
      first_entry || %{"_id" => 0}
    end).() |>
      Map.get("_id") |>
    (fn(id) -> id + 1 end).()
  end

  def new_or_old_id(entry), do: if entry.id == 0, do: Map.merge(entry, %{:id => next_entry_id()}), else: entry
  def dating(entry) do
    if is_number entry.created_at do
      if entry.created_at == 0 do
        Map.merge(entry, %{:created_at => DateTime.to_unix(DateTime.utc_now) * 1000})
      else
          entry
      end
    else
          # Parse numerical date string - ie 201807211537
          Map.merge(entry, %{:created_at => DateTime.to_unix(DateTime.utc_now) * 1000})
    end
  end

  def parse_entry_file(file_as_string) do
    [header | entry] = String.split(file_as_string, ~r/\n{2,}/)
    # IO.inspect header
    header_map = String.split(header, ~r/\n/) |> Enum.reduce(%Martenblog.Entry{}, fn(line, acc) ->
      arr_of_tuples = Enum.map(Keyword.keys(@header_res), 
        fn(key) -> 
          # IO.puts "key -> #{key} line -> #{line}"
            # IO.inspect @header_res[key]
            # IO.inspect(Regex.run(@header_res[key], line))
          {key, Regex.run(@header_res[key], line)} 
        end) |> Enum.reject(fn({_, capture}) -> 
          is_nil(capture) 
        end)
        # IO.inspect arr_of_tuples
      case arr_of_tuples do
        [{key, [_, capture]}] ->
          cap = cond do
            key == :id ->
              case Float.parse(capture) do
                :error ->
                  next_entry_id()
                {id_float, _} ->
                  trunc id_float
              end
            key == :created_at ->
              Logger.info "key: #{key} - capture: #{capture}"
              parse_mb_timestamp(capture)
            true ->
              capture
          end
          Map.merge(acc, %{key => cap})
        _ ->
          topic_match = Regex.run(@topic_re, line)
          if is_nil(topic_match) do
            acc
          else
            [_, capture] = topic_match
            Map.merge(acc, %{:topic_ids => topic_ids_from_topics_string(capture)})
          end
      end
    end) 
    hashtag_topics = Enum.flat_map(entry, fn(line) -> 
      Regex.scan(~r/#(\w+)\b/, line) |> Enum.map(fn(m) -> Enum.drop(m, 1) |> List.first |> String.downcase end) 
    end) |> Enum.uniq
    IO.inspect hashtag_topics
    topic_ids = Enum.concat(header_map.topic_ids, if !Enum.empty?(hashtag_topics) do
      topic_ids_from_topics_array(hashtag_topics)
    else
      []
    end)
    Map.merge(header_map, %{:topic_ids => topic_ids, :entry => Enum.join(entry, "\n\n")}) |> new_or_old_id |> dating 
  end

  def write_processed_file(filename, entry) do
    case Regex.run(~r<^([-\w/]+)/([-\w]+)\.(\w+)$>, filename) do
      nil ->
        Logger.info "#{filename} could not be parsed to write processed file"
      [_, path, buttock, extension] ->
        Logger.info "path: #{path}, buttock: #{buttock}, extension: #{extension}"
        processed_filename = "#{path}/#{buttock}_processed.#{extension}"
        topics = Topic.topic_ids_to_topics_string(entry.topic_ids) |> Enum.join(",")
        contents = "_id: #{entry.id}\nDate: #{entry.created_at}\nSubject: #{entry.subject}\nTopic: #{topics}\n\n#{entry.entry}"
        File.write(processed_filename, contents)
    end
  end

  def new_entry(filename) do
    case File.read(filename) do
      {:error, error} ->
        Logger.info "#{filename} not found, or somesuch"
        Logger.info error
      {:ok, f} ->
        entry = parse_entry_file f
        Enum.each(entry.topic_ids, fn(topic_id) -> Topic.add_entry_id_to_topic(topic_id, entry.id) end)
        Mongo.insert_one(:mongo, "entry", to_mongoable(entry))
        write_processed_file(filename, entry)
        entry
    end
  end

  def check_entry_files(dir, re) do
    File.ls!(dir) |> Enum.reject(fn(file) -> is_nil(Regex.run(re, file)) end) |> Enum.each(fn(file) ->
      path = Path.join(dir, file)
      f = File.read!(path)
      entry = parse_entry_file f
      mentry = Mongo.find(:mongo, "entry", %{"subject" => String.trim(entry.subject)})
      if mentry do

      end
    end)
  end

  def count do
    case Mongo.count(:mongo, "entry", %{}) do
      {:ok, c} -> c
      _ ->
        Logger.info "Entry.count returned something erratic"
        0
    end
  end

  def subjects do
    Mongo.find(:mongo, "entry", %{}, sort: %{"created_at" => -1}) |> Enum.to_list |> Enum.map(&Utils.normalise_keys/1)
  end

  def published(id) do
    mentry = Mongo.find_one(:mongo, "entry", %{"_id" => id})
    if is_nil mentry do
      nil
    else  
      DateTime.from_unix!(Kernel.trunc(Map.get(mentry, "created_at") / 1000)) |> DateTime.to_iso8601
    end
  end

  def date_link(id) do
    case date_path(id) do
      :error -> "/#/blog/1"
      {:ok, dp} -> "/#/blog/#{dp}"
    end
  end

  def date_link_static(id) do
    case date_path(id) do
      :error -> "/blog/1"
      {:ok, dp} -> "/blog/#{dp}"
    end
  end

  def date_path(id) do
    mentry = Mongo.find_one(:mongo, "entry", %{"_id" => id})
    if is_nil(mentry) do
      :error
    else
      d = DateTime.from_unix!(Kernel.trunc(Map.get(mentry, "created_at") / 1000))
      {:ok, "#{d.year}/#{d.month}/#{d.day}"}
    end
  end

  def permalink(id) do
    "/entry/by-id/#{id}"
  end

  def entry(id) do
    mentry = Mongo.find_one(:mongo, "entry", %{"_id" => id})
    if is_nil mentry do
      nil
    else
      Map.get(mentry, "entry")
    end
  end

  def subject(id) do
    mentry = Mongo.find_one(:mongo, "entry", %{"_id" => id})
    if is_nil mentry do
      nil
    else
      Map.get(mentry, "subject")
    end
  end

  def entry_count do
    case Mongo.count_documents(:mongo, "entry", %{}) do
      {:ok, count} -> count
      _ -> 0
    end
  end

  def count_federated_entries do
    case Mongo.count(:mongo, "entry", %{ federated: true }) do
      {:ok, count} -> count
      _ -> 0
    end
  end

  def federated_entry_ids, do: Mongo.find(:mongo, "entry", %{federated: true}) |> Enum.to_list |> Enum.map(fn e -> Map.get(e, "_id") end)

  def mark_federated(id, federated_to \\ []) do
    mentry = Mongo.find_one(:mongo, "entry", %{"_id" => id})
    if !is_nil(mentry) do
      to_federate = if Enum.empty? federated_to do
        APResolver.followers
      else
        federated_to
      end |> MapSet.new |> MapSet.union((fn () -> 
        mentry_federated_to = Map.get(mentry, "federated_to")
        if is_nil mentry_federated_to do
          MapSet.new
        else
          MapSet.new(mentry_federated_to)
        end
      end).()) |> MapSet.to_list 
      IO.puts "to_federate"
      IO.inspect to_federate
      now = DateTime.utc_now |> DateTime.to_unix |> (fn ts -> ts * 1000 end).()
      Mongo.update_one(:mongo, "entry",  %{"_id" => id}, %{"$set" => %{ "federated" => true, "federated_ts" => now, "federated_to" => to_federate }})
    end
  end

  def clear_federated(id) do
    mentry = Mongo.find_one(:mongo, "entry", %{"_id" => id})
    if !is_nil(mentry) do
      Mongo.update_one(:mongo, "entry", %{"_id" => id}, %{"$set" => %{ "federated" => false, "federated_ts" => nil, "federated_to" => [] }})
    end
  end
end
