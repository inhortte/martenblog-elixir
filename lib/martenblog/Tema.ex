defmodule Martenblog.Tema do
  require Logger
  alias Martenblog.Utils
  @stasis_dir "/home/polaris/arch-my-hive/martenblog/stasis"
  @topics_file "#{@stasis_dir}/topics"

  def all do
    with {:fetch, {:ok, file}} <- {:fetch, File.read(@topics_file)},
      {:decode, {:ok, topics}} <- {:decode, Poison.decode(file)} do
      topics |> Enum.map(fn topic -> topic |> Utils.normalise_keys end)
    else
      {:fetch, {:error, reason}} ->
        Logger.error "#{@topics_file} possibly doesn't exist: #{reason}"
        []
      {:decode, {:error, reason}} ->
        Logger.error "Couldn't parse topics file: #{inspect(reason, pretty: true)}"
        []
    end
  end

  def topics_by_ids(ids) do
    all() |> Enum.filter(fn topic -> ids |> Enum.any?(fn id -> topic.id == id end) end)
  end

  def topics_by_names(names) do
    all() |> Enum.filter(fn topic -> names |> Enum.any?(fn name -> topic.topic == String.trim(name) end) end)
  end

  def topic_ids_to_topics_string(ids) do
    ids |> topics_by_ids |> Enum.map(fn topic -> topic.topic end)
  end

  def next_topic_id(topics) do
    topics |> Enum.max(fn (a, b) -> a.id > b.id end) |> Map.get(:id) |> Kernel.+(1)
  end

  def save(topics, topic) do
    topics |> Enum.reduce([], fn (t, ts) ->
      ts ++ (if t.id == topic.id, do: [ topic ], else: [ t ])
    end) |> Poison.encode!(pretty: true) |> (fn json -> File.write!(@topics_file, json) end).()
    topic
  end

  def new_topic(topics, topic_string, entry_created_at) do
    topic = %{
      id: next_topic_id(topics),
      entries: [entry_created_at],
      topic: topic_string
    } 
    (topics ++ [ topic ]) |> Poison.encode!(pretty: true) |> (fn json -> File.write!(@topics_file, json) end).()
    topic
  end

  def add_entry_to_topic(topic_string, entry_created_at) do
    topics = all()
    topics |> Enum.find(fn topic -> topic.topic == topic_string end) |> case do
      nil -> new_topic(topics, topic_string, entry_created_at)
      topic ->
        updated_topic = Map.update(
          topic, :entries, [entry_created_at], 
          fn entries -> [entry_created_at|entries] end
        )
        save(topics, updated_topic)
    end
  end
end
