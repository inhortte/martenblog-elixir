defmodule Martenblog.Http do
  require Logger
  alias Martenblog.Topic
  alias Martenblog.Entry
  alias Martenblog.Utils
  @releases_dir "/home/polaris/Elements/flavigula/release/"
  @eex "/home/polaris/rummaging_round/elixir/martenblog-elixir/web/static/"
  @dest "/home/polaris/rummaging_round/elixir/martenblog-elixir/web/public/static"
  
  def page(page) do
    Entry.subjects |> Enum.drop((page - 1) * div(Entry.count, 11) * 11) |> Enum.take(11) |>
    Enum.map(fn e ->
      topics = Topic.topics_by_ids(e.topic_ids) |> Enum.map(fn t -> Map.get(t, "topic") end)
      # IO.inspect topics
      IO.inspect e.created_at
      timex_time = Timex.from_unix(div(e.created_at, 1000))
      ostensible_date = case Timex.Format.DateTime.Formatters.Strftime.format(timex_time, "%Z") do
        {:ok, ""} -> "An unknown moment during the void"
        {:ok, tz} ->
          tzone = tz |> String.split("/") |> Enum.drop(1) |> List.first
          rest_of_date = Timex.Format.DateTime.Formatters.Strftime.format!(timex_time,
            "%a, %d %b, %Y %H.%M")
          "#{rest_of_date} #{tzone}"
        _ -> "An unknown moment during the void"
      end
      entry_truncated = "#{String.slice(e.entry, 0, 512)}..."
      EEx.eval_file(Path.join([@eex, "entry_in_page.eex"]), [topics: topics, ostensible_date: ostensible_date, subject: e.subject, entry_trunctated: entry_truncated])
    end) |>
    (fn es ->
      content = Enum.join(es)
      html = EEx.eval_file(Path.join([@eex, "blog.eex"]), [content: content])
      File.write!(Path.join(@dest, "blog/page_#{page}.html"), html)
    end).()
  end
end
