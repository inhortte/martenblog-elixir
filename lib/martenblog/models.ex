defmodule Martenblog.Topic do
  require Logger
  alias Martenblog.Utils

  defstruct id: 0, topic: "", entry_ids: [], created_at: DateTime.utc_now

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
end

defmodule Martenblog.Entry do
  require Logger

  @id_re ~r/^_id:\s+(\d+)\s*$/
  @subject_re ~r/^[Ss]ubject:\s+(.+)$/
  @date_re ~r/^(\d+)\s*$/
  @topic_re ~r/^[Tt]opics?:\s+(.+)$/

  @header_res [id: @id_re, subject: @subject_re, created_at: @date_re]

  defstruct id: 0, created_at: DateTime.to_unix(DateTime.utc_now) * 1000, entry: "", subject: "", topic_ids: [], user_id: 1

  def topic_ids_from_topics_string(ts) do
    String.split(ts, ~r/\s*,\s*/) |> Enum.map(fn(s) ->
      topic = String.trim(s) |> String.downcase
      topics = Martenblog.Topic.all
      Enum.find(topics, fn(t) -> t.topic == topic end).id
    end)
  end

  def next_entry_id() do
    Mongo.find(:mongo, "entry", %{}, sort: %{"_id" => -1}, limit: 1) |> Enum.to_list |> List.first |> Map.get("_id") |> (fn(id) -> id + 1 end).()
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
    end) |> Map.merge(%{:entry => Enum.join(entry, "\n\n")}) |> (fn(e) -> if e.id == 0, do: Map.merge(e, %{:id => next_entry_id()}), else: e end).()
  end
end
