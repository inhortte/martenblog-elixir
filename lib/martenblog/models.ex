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

  def next_topic_id() do
    Mongo.find(:mongo, "topic", %{}, sort: %{"_id" => -1}, limit: 1) |> Enum.to_list |> List.first |> Map.get("_id") |> (fn(id) -> id + 1 end).()
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
    case Mongo.update_one(:mongo, "topic", %{"_id" => topic_id}, %{"$addToSet": %{"entry_ids": entry_id}}) do
      {:ok, _} ->
	Logger.info "added entry #{entry_id} to topic #{topic_id}"
      _ ->
	Logger.info "could not add entry #{entry_id} to topic #{topic_id}"
    end
  end

  def topic_ids_to_topics_string(topic_ids) do
    Mongo.find(:mongo, "topic", %{"_id" => %{"$in" => topic_ids}}) |> Enum.map(fn(topic) -> topic["topic"] end) |> Enum.join(",")
  end
end

defmodule Martenblog.Entry do
  require Logger
  alias Martenblog.Topic

  @id_re ~r/^_id:\s+(\d+)\s*$/
  @subject_re ~r/^[Ss]ubject:\s+(.+)$/
  @date_re ~r/^(\d+)\s*$/
  @topic_re ~r/^[Tt]opics?:\s+(.+)$/

  @header_res [id: @id_re, subject: @subject_re, created_at: @date_re]

  defstruct id: 0, created_at: 0, entry: "", subject: "", topic_ids: [], user_id: 1
  @oddities %{:id => "_id"}  

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

  def topic_ids_from_topics_string(ts) do
    String.split(ts, ~r/\s*,\s*/) |> Enum.map(fn(s) ->
      topic_string = String.trim(s) |> String.downcase
      topics = Topic.all
      topic = Enum.find(topics, fn(t) -> t.topic == topic_string end)
      if is_nil(topic) do
	Topic.new_topic(topic_string)
      else
	topic.id
      end
    end)
  end

  def next_entry_id() do
    Mongo.find(:mongo, "entry", %{}, sort: %{"_id" => -1}, limit: 1) |> Enum.to_list |> List.first |> Map.get("_id") |> (fn(id) -> id + 1 end).()
  end

  def new_or_old_id(entry), do: if e.id == 0, do: Map.merge(e, %{:id => next_entry_id()}), else: e 
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
    String.split(header, ~r/\n/) |> Enum.reduce(%Martenblog.Entry{}, fn(line, acc) ->
      arr_of_tuples = Enum.map(Keyword.keys(@header_res), fn(key) -> {key, Regex.run(@header_res[key], line)} end) |> Enum.reject(fn({_, capture}) -> is_nil(capture) end)
      case arr_of_tuples do
	[{key, [_, capture]}] ->
	  cap = if key == :id do
	      case Float.parse(capture) do
		:error ->
		  next_entry_id()
		{id_float, _} ->
		  trunc id_float
	      end
	    else
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
    end) |> Map.merge(%{:entry => Enum.join(entry, "\n\n")}) |> new_or_old_id |> dating 
  end

  def write_processed_file(filename, entry) do
    case Regex.run(~r<^([-\w/]+)/([-\w]+)\.(\w+)$>, filename) do
      nil ->
	Logger.info "#{filename} could not be parsed to write processed file"
      [_, path, buttock, extension] ->
	Logger.info "path: #{path}, buttock: #{buttock}, extension: #{extension}"
	processed_filename = "#{path}/#{buttock}_processed.#{extension}"
	contents = "_id: #{entry.id}\nDate: #{entry.created_at}\nSubject: #{entry.subject}\nTopic: #{Topic.topic_ids_to_topics_string(entry.topic_ids)}\n\n#{entry.entry}"
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
end
