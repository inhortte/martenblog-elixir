defmodule Martenblog.Gemini do
  require Logger
  alias Martenblog.Topic
  alias Martenblog.Entry
  alias Martenblog.Utils

  def blog_entry_to_gemini(id) do
    Entry.get_entry_by_id(id) |>
    (fn(entry) ->
      filename = "/tmp/#{Utils.randomFilename}"
      File.write!(filename, Map.get(entry, :entry))
      thurk = Port.open(
        {:spawn, "md2gemini -l at-end #{filename}"},
        [:binary]
      )
      topics = Topic.topics_by_ids(Map.get(entry, :topic_ids)) |> 
      Enum.map(fn t -> Map.get(t, "topic") end) |> 
      Enum.join(", ")
      receive do
        {^thurk, {:data, result}} ->
          """
          # #{Map.get(entry, :subject)}
          ## Topics: #{topics}
          ## #{Map.get(entry, :created_at)}

          #{result}
          """
      end |> (fn text -> File.write!("/home/polaris/src/blizanci/public_gemini/blog/#{id}.gemini", text) end).()
    end).()
  end

  def make_index(count) do
    Entry.subjects(count) |> Enum.map(fn e ->
      "=> #{Map.get(e, :id)}.gemini #{Map.get(e, :subject)}\n"
    end) |> (fn subject_list ->
      affirmation = """
      # The Martenblog

      #{subject_list}
      """
      File.write!("/home/polaris/src/blizanci/public_gemini/blog/index.gemini", affirmation)
    end).()
  end

  def slap_um_in(count) do
    make_index(count)
    Entry.subjects(count) |> Enum.each(fn e -> blog_entry_to_gemini(Map.get(e, :id)) end)
  end
end
