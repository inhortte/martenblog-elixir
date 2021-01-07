defmodule Martenblog.Http do
  require Logger
  alias Martenblog.Topic
  alias Martenblog.Entry
  alias Martenblog.Utils
  @releases_dir "/home/polaris/Elements/flavigula/release/"
  @eex "/home/polaris/rummaging_round/elixir/martenblog-elixir/web/static/"
  @dest "/home/polaris/rummaging_round/elixir/martenblog-elixir/web/public/static/"
  @gemini_base "/usr/share/molly/"

  def pagination(page) do
    page_count = div(Entry.count, 11) + (if rem(Entry.count, 11) > 0, do: 1, else: 0)
    first_page = %{
      label: "«",
      disabled: page == 1,
      link: "/static/blog/page_1.html",
      aria_label: "Go to first page"
    }
    last_page = %{
      label: "»",
      disabled: page == page_count,
      link: "/static/blog/page_#{page_count}.html",
      aria_label: "Go to last page"
    }
    previous_page = %{
      label: "‹",
      disabled: page == 1,
      link: (if page == 1, do: "/static/blog/page_1.html", else: "/static/blog/page_#{page - 1}.html"),
      aria_label: "Go to previous page"
    }
    next_page = %{
      label: "›",
      disabled: page == page_count,
      link: if(page == page_count, do: "/static/blog/page_#{page_count}.html", else: "/static/blog/page_#{page + 1}.html"),
      aria_label: "Go to next page"
    }
    pages = 0..3 |> Enum.to_list |> Enum.map(fn p ->
      n = cond do
        page < 3 -> p + 1
        page > (page_count - 2) -> p + page_count - 3
        true -> p + page - 1
      end
      %{
        label: n,
        disabled: page == n,
        link: "/static/blog/page_#{n}.html",
        aria_label: "Go to page #{page}"
      }
    end)
    Enum.concat([
      [first_page, previous_page],
      pages,
      [next_page, last_page]
    ])
  end

  def presentable_date(timex_time, format, with_tz \\ false) do
    case Timex.Format.DateTime.Formatters.Strftime.format(timex_time, "%Z") do
      {:ok, ""} -> "An unknown moment during the void"
      {:ok, tz} ->
        tzone = tz |> String.split("/") |> Enum.drop(1) |> List.first
        rest_of_date = Timex.Format.DateTime.Formatters.Strftime.format!(timex_time,
          format)
        if with_tz, do: "#{rest_of_date} #{tzone}", else: rest_of_date
      _ -> "An unknown moment during the void"
    end
  end

  def pd_from_ut(unix_time, format, with_tz \\ false) do
    presentable_date(Timex.from_unix(unix_time), format)
  end
  
  def page(page) do
    Entry.subjects |> Enum.drop((page - 1) * 11) |> Enum.take(11) |>
    Enum.map(fn e ->
      topics = Topic.topics_by_ids(e.topic_ids) |> Enum.map(fn t -> 
        if is_nil(t), do: "unknown", else: Map.get(t, "topic", "unknown") 
      end)
      # IO.inspect topics
      IO.inspect e.created_at
      unix_time = floor(e.created_at / 1000)
      timex_time = Timex.from_unix(unix_time)
      link = Timex.from_unix(unix_time) |> Timex.beginning_of_day |> Timex.to_unix
      ostensible_date = presentable_date(timex_time, "%a, %d %b, %Y %H.%M", true)
      entry_truncated = "#{String.slice(e.entry, 0, 512)}..."
      EEx.eval_file(Path.join([@eex, "entry_in_page.eex"]), [topics: topics, ostensible_date: ostensible_date, subject: e.subject, link: "/static/blog/#{link}.html", entry_trunctated: entry_truncated])
    end) |>
    (fn es ->
      pagination_hovno = pagination(page)
      content = Enum.join(es)
      html = EEx.eval_file(Path.join([@eex, "blog.eex"]), [content: content, pages: pagination_hovno])
      File.write!(Path.join(@dest, "blog/page_#{page}.html"), html)
    end).()
  end

  def pages do
    page_count = div(Entry.count, 11) + (if rem(Entry.count, 11) > 0, do: 1, else: 0)
    1..page_count |> Enum.each(&page/1)
  end

  def date_placement(entry, date_map) do
    key = Timex.from_unix(floor(entry.created_at / 1000)) |> Timex.beginning_of_day |> Timex.to_unix
    Map.merge(date_map, 
      if Map.has_key?(date_map, key) do
        %{key => [entry|Map.get(date_map, key)]}
      else
        %{key => [entry]}
      end)
  end

  def date_entries do
    date_map = Entry.subjects |> Enum.reduce(%{}, &date_placement/2)
    high_point = length(Map.keys(date_map))-1
    date_array = Enum.zip(0..high_point, Map.keys(date_map) |> Enum.sort(fn a, b -> b < a end)) |> Enum.into(%{})
    0..high_point |> Enum.to_list |> Enum.each(fn idx ->
      meta = %{
        previous: (if idx < high_point, do: pd_from_ut(Map.get(date_array, idx+1), "%a, %d %b, %Y", false), else: nil),
        previous_link: (if idx < high_point, do: "/static/blog/#{Map.get(date_array, idx+1)}.html", else: nil),
        next: (if idx > 0, do: pd_from_ut(Map.get(date_array, idx-1), "%a, %d %b, %Y", false), else: nil),
        next_link: (if idx > 0, do: "/static/blog/#{Map.get(date_array, idx-1)}.html", else: nil)
      }
      entries = Map.get(date_map, Map.get(date_array, idx)) |> Enum.map(fn entry ->
        topics = Topic.topics_by_ids(entry.topic_ids) |> Enum.map(fn t -> 
          if is_nil(t), do: "unknown", else: Map.get(t, "topic", "unknown") 
        end)
        %{
          entry: Earmark.as_html!(entry.entry),
          subject: entry.subject,
          date: pd_from_ut(floor(entry.created_at / 1000),"%a, %d %b, %Y %H:%M", true),
          topics: topics
        }
      end)
      html = EEx.eval_file(Path.join([@eex, "date-entry.eex"]), [meta: meta, entries: entries])
      File.write!(Path.join(@dest, "blog/#{Map.get(date_array, idx)}.html"), html)
    end)
  end

  def tag(tag_type) do
    fn incoming, append ->
      "#{incoming}<#{tag_type}>#{append}\n"
    end
  end

  def h4(append), do: h4("", append)
  def h5(append), do: h5("", append)
  def h6(append), do: h6("", append)
  def h4(incoming, append), do: tag("h4").(incoming, append) <> "</h4>\n"
  def h5(incoming, append), do: tag("h5").(incoming, append) <> "</h5>\n"
  def h6(incoming, append), do: tag("h6").(incoming, append) <> "</h6>\n"
  def p(append), do: p("", append)
  def p(incoming, append), do: tag("p").(incoming, append) <> "</p>\n"
  def bqstart(append), do: bqstart("", append)
  def bqstart(incoming, append), do: tag("blockquote").(incoming, append)
  def ulli(append), do: ulli("", append)
  def ulli(incoming, append), do: tag("div").(incoming, "") <> tag("ul").("", "") <> tag("li").("", append) <> "</li>\n"
  def li(append), do: tag("li").("", append) <> "</li>\n"
  def hr(incoming), do: "#{incoming}<hr />"
  def ulend do
    fn -> tag("/div").("", "") <> tag("/ul").("", "") end
  end
  def bqend do
    fn -> tag("/blockquote").("", "") end
  end
  def nuluend do
    fn -> "\n" end
  end

  def no_spaces(text, endfn) do
    cond do
      Regex.match?(~r/^--+$/, text) -> 
        {:ok, endfn.() |> hr(), :nulu}
      Regex.match?(~r/^\s*$/, text) -> 
          {:ok, endfn.(), :nulu}
      true -> 
        {:ok, endfn.() |> p(text), :nulu}
    end
  end

  def line_link(line) do
    re = ~r/^([^\s]+)\s+(.+)$/
    case Regex.run(re, line) do
      [_, uri, text] ->
        if Regex.match?(~r/^(http|gemi|ftp)/, uri) do
          {:ok, ~s(<a href="#{uri}">#{text}</a><br />\n)}
        else
          {:ok, ~s(<a href="#{uri}">#{text}</a><br />\n)}
        end
      _ -> {:error, :invalid}
    end
  end

  def nulu_line(line) do
    case String.split(line, ~r/\s+/) do
      [text] -> text |> no_spaces(nuluend())
      [head|tail] ->
        text = Enum.join(tail, " ")
        case head do
          "*" -> {:ok, ulli(text), :ul}
          ">" -> {:ok, bqstart(text), :blockquote}
          "#" -> {:ok, h4(text), :nulu}
          "##" -> {:ok, h5(text), :nulu}
          "###" -> {:ok, h6(text), :nulu}
          "=>" ->
            case line_link(text) do
              {:ok, link} -> {:ok, link, :nulu}
              {:error, _error} -> {:ok, p(text), :nulu}
            end
          _ -> {:ok, p(Enum.join([head|tail], " ")), :nulu}
        end
    end
  end

  def ul_line(line) do
    case String.split(line, ~r/\s+/) do
      [text] -> text |> no_spaces(ulend())
      [head|tail] ->
        text = Enum.join(tail, " ")
        case head do
          "*" -> {:ok, li(text), :ul}
          ">" -> {:ok, ulend().() |> bqstart(text), :blockquote}
          "#" -> {:ok, ulend().() |> h4(text), :nulu}
          "##" -> {:ok, ulend().() |> h5(text), :nulu}
          "###" -> {:ok, ulend().() |> h6(text), :nulu}
          "=>" ->
            case line_link(text) do
              {:ok, link} -> {:ok, ulend().() <> link, :nulu}
              {:error, _error} -> {:ok, ulend().() <> p(text), :nulu}
            end
          _ -> {:ok, ulend().() |> p(Enum.join([head|tail], " ")), :nulu}
        end
    end
  end

  def bq_line(line) do
    case String.split(line, ~r/\s+/) do
      [text] -> text |> no_spaces(bqend())
      [head|tail] ->
        text = Enum.join(tail, " ")
        case head do
          "*" -> {:ok, bqend().() |> ulli(text), :ul}
          ">" -> {:ok, "#{text}\n", :blockquote}
          "#" -> {:ok, bqend().() |> h4(text), :nulu}
          "##" -> {:ok, bqend().() |> h5(text), :nulu}
          "###" -> {:ok, bqend().() |> h6(text), :nulu}
          "=>" ->
            case line_link(text) do
              {:ok, link} -> {:ok, bqend().() <> link, :nulu}
              {:error, _error} -> {:ok, bqend().() <> p(text), :nulu}
            end
          _ -> {:ok, bqend().() |> p(Enum.join([head|tail], " ")), :nulu}
        end
    end
  end

  def process_gemini_line(line, status) do
    case status do
      :nulu -> nulu_line(line)
      :ul -> ul_line(line)
      :blockquote -> bq_line(line)
    end
  end

  def process_gemini([], html_list, status) do
    case process_gemini_line("", status) do
      {:ok, line, _status} -> Enum.reverse([line|html_list]) |> Enum.join("\n")
      _ -> Enum.reverse(html_list) |> Enum.join("\n")
    end
  end
  def process_gemini([head|tail], html_list, status) do
    case process_gemini_line(head, status) do
      {:ok, line, status} -> process_gemini(tail, [line|html_list], status)
      _ -> process_gemini(tail, html_list, :nulu)
    end
  end

  def gemini_to_html(path, options) do
    case File.read(path) do
      {:ok, file} ->
        lined = String.split(file, ~r/\n/)
        modified = case options do
          %{head_lop: head_lop} -> lined |> Enum.drop(head_lop)
          _ -> lined
        end
        {:ok, process_gemini(modified, [], :nulu)}
      {:error, error} -> {:error, error}
    end
  end

  def process_gemini_file(relative_path, template, options \\ %{}) do
    gemini_path = Path.join([@gemini_base, relative_path]) <> ".gmi"
    Logger.info "gemini path -> " <> gemini_path
    html_path = Path.join([@dest, relative_path]) <> ".html"
    Logger.info "html path -> " <> html_path
    case gemini_to_html(gemini_path, options) do
      {:ok, content} ->
        html = EEx.eval_file(Path.join([@eex, "#{template}.eex"]), [content: content]) 
        File.write!(html_path, html)
      {:error, error} -> {:error, error}
    end
  end
end
