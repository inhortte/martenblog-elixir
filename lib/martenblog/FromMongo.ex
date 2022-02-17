defmodule Martenblog.FromMongo do
  require Logger
  alias Martenblog.{Topic, Entry}
  @stasis_dir "/home/polaris/arch-my-hive/martenblog/stasis"
  @topics_file "#{@stasis_dir}/topics"

  def timestamp_to_date(%{created_at: created_at}), do: ts_to_date(created_at)
  def timestamp_to_date(%{"created_at" => created_at}), do: ts_to_date(created_at)
  defp ts_to_date(created_at) do
    created_at |> Kernel.trunc |> div(1000) |>
      DateTime.from_unix |> case do
        {:ok, dt} -> dt
        {:error, _} -> DateTime.now!("Etc/UTC")
      end |> (fn dt ->
      [dt.year, dt.month, dt.day, dt.hour, dt.minute] |>
        Enum.map(&to_string/1) |>
        Enum.map(&String.pad_leading(&1, 2, "0")) |>
        Enum.join
    end).()
  end

  def topics_to_file do
    Topic.all |> Enum.map(fn topic ->
      entries = topic.entry_ids |> Enum.map(fn id ->
        Entry.get_entry_by_id(id) |> case do
          nil -> nil
          entry -> entry |> timestamp_to_date
        end
      end) |> Enum.reject(&is_nil/1)
      %{topic: topic.topic, id: Kernel.trunc(topic.id), entries: entries}
    end) |> Poison.encode!(pretty: true) |> (fn json -> File.write!(@topics_file, json) end).()
    "finito"
  end

  def entries_to_files do
    Entry.all |> Enum.map(fn entry ->
      topics = entry.topic_ids |> Enum.map(fn id -> 
        Topic.topic_by_id(Kernel.trunc(id)) |> 
          case do
            nil -> nil
            topic -> topic.topic
          end
      end) |> 
        Enum.reject(&is_nil/1) |>
        Enum.map(&String.trim/1) |>
        Enum.join(",")
      filename = timestamp_to_date(entry)
      """
      id: #{Kernel.trunc(entry.id)}
      date: #{filename}
      topic: #{topics}
      subject: #{entry.subject}

      #{entry.entry}
      """ |> 
        (fn agglutination ->
          File.write!("#{@stasis_dir}/#{filename}_processed.md", agglutination)
        end).()
    end)
    "finito"
  end
end
