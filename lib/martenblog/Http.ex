defmodule Martenblog.Http do
  import Martenblog.Transform
  require Logger
  alias Martenblog.{Tema,Anotacion,Utils,PoemResolver}
# @releases_dir "/home/polaris/Elements/flavigula/release/"
  @eex "/home/polaris/rummaging_round/elixir/martenblog-elixir/web/static/"
  @eex_marmota "/home/polaris/elixir/martenblog-elixir/web/static/"
  @dest "/home/polaris/rummaging_round/elixir/martenblog-elixir/web/public/static/"
  @dest_marmota "/home/polaris/elixir/martenblog-elixir/web/public/static/"
  @gemini_base "/usr/share/molly/"
  @poems_dest "#{@dest}poems"
  @poems_marmota_dest "#{@dest_marmota}poems"
  @reference_re ~r/\[([0-9a-z])\]/
  @footnote_re ~r/^=>\s+([^\s]+)\s+([0-9a-z])\.\s+(.+)$/

  def eex_base do
    case :inet.gethostname do
      {:ok, hostname} -> :thurk
        if Regex.match?(~r/marmota/, List.to_string(hostname)) do
          @eex_marmota
        else
          @eex
        end
      _ -> @eex
    end
  end

  def dest_base do
    case :inet.gethostname do
      {:ok, hostname} -> :thurk
        if Regex.match?(~r/marmota/, List.to_string(hostname)) do
          @dest_marmota
        else
          @dest
        end
      _ -> @dest
    end
  end

  def poems_dest do
    case :inet.gethostname do
      {:ok, hostname} ->
        if Regex.match?(~r/marmota/, List.to_string(hostname)) do
          @poems_marmota_dest
        else
          @poems_dest
        end
      _ -> @poems_dest
    end
  end

  def pagination(page) do
    e_count = Anotacion.count
    page_count = div(e_count, 11) + (if rem(e_count, 11) > 0, do: 1, else: 0)
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
        active: page == n,
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

  def pd_from_ut(unix_time, format) do
    presentable_date(Timex.from_unix(unix_time), format)
  end

  def pd_from_md(md) do
    Utils.from_mb_to_dt(md) |> 
      presentable_date("%a, %d %b, %Y %H.%M", true)
  end

  def link_from_md(md) do
    Utils.from_mb_to_dt(md) |>
      Timex.beginning_of_day |> Timex.to_unix
  end
  
  def page(page) do
    Anotacion.page(page) |>
      Enum.map(fn e ->
        topics = Tema.topics_by_names(e.topic) |> Enum.map(fn t -> t.topic end)
        Logger.info "Topics for #{e.id} are #{inspect topics}"
        ostensible_date = pd_from_md(e.date)
        entry_truncated = "#{String.slice(e.entry, 0, 512)}..."
        link = link_from_md(e.date);
        EEx.eval_file(Path.join([eex_base(), "entry_in_page.eex"]), [meta_tags: %{}, topics: topics, ostensible_date: ostensible_date, subject: e.subject, link: "/static/blog/#{link}.html", entry_trunctated: entry_truncated])
      end) |>
    (fn es ->
      pagination_hovno = pagination(page)
      content = Enum.join(es)
      html = EEx.eval_file(Path.join([eex_base(), "blog.eex"]), [meta_tags: %{}, content: content, pages: pagination_hovno, title: "Mustelid Musings"])
      File.write!(Path.join(dest_base(), "blog/page_#{page}.html"), html)
    end).()
#    Entry.subjects |> Enum.drop((page - 1) * 11) |> Enum.take(11) |>
#    Enum.map(fn e ->
#      topics = Topic.topics_by_ids(e.topic_ids) |> Enum.map(fn t -> 
#        if is_nil(t), do: "unknown", else: Map.get(t, "topic", "unknown") 
#      end)
#      # IO.inspect topics
#      IO.inspect e.created_at
#      unix_time = floor(e.created_at / 1000)
#      timex_time = Timex.from_unix(unix_time)
#      link = Timex.from_unix(unix_time) |> Timex.beginning_of_day |> Timex.to_unix
#      ostensible_date = presentable_date(timex_time, "%a, %d %b, %Y %H.%M", true)
#      entry_truncated = "#{String.slice(e.entry, 0, 512)}..."
#      EEx.eval_file(Path.join([eex_base(), "entry_in_page.eex"]), [meta_tags: %{}, topics: topics, ostensible_date: ostensible_date, subject: e.subject, link: "/static/blog/#{link}.html", entry_trunctated: entry_truncated])
#    end) |>
#    (fn es ->
#      pagination_hovno = pagination(page)
#      content = Enum.join(es)
#      html = EEx.eval_file(Path.join([eex_base(), "blog.eex"]), [meta_tags: %{}, content: content, pages: pagination_hovno, title: "Mustelid Musings"])
#      File.write!(Path.join(dest_base, "blog/page_#{page}.html"), html)
#    end).()
  end

  def pages do
    e_count = Anotacion.count
    page_count = div(e_count, 11) + (if rem(e_count, 11) > 0, do: 1, else: 0)
    1..page_count |> Enum.each(&page/1)
  end

  def date_placement(entry, date_map) do
    key = entry.date |> Utils.from_mb_to_date_link
    Map.merge(date_map, 
      if Map.has_key?(date_map, key) do
        %{key => [entry|Map.get(date_map, key)]}
      else
        %{key => [entry]}
      end)
  end

  def date_entries do
    date_map = Anotacion.all |> Enum.reduce(%{}, &date_placement/2)
    high_point = length(Map.keys(date_map))-1
    date_array = Enum.zip(0..high_point, Map.keys(date_map) |> Enum.sort(fn a, b -> b < a end)) |> Enum.into(%{})
    0..high_point |> Enum.to_list |> Enum.each(fn idx ->
      meta = %{
        previous: (if idx < high_point, do: pd_from_ut(Map.get(date_array, idx+1), "%a, %d %b, %Y"), else: nil),
        previous_link: (if idx < high_point, do: "/static/blog/#{Map.get(date_array, idx+1)}.html", else: nil),
        next: (if idx > 0, do: pd_from_ut(Map.get(date_array, idx-1), "%a, %d %b, %Y"), else: nil),
        next_link: (if idx > 0, do: "/static/blog/#{Map.get(date_array, idx-1)}.html", else: nil)
      }
      entries = Map.get(date_map, Map.get(date_array, idx)) |> Enum.map(fn entry ->
        #topics = Tema.topics_by_names(entry.topic) |> Enum.map(fn t -> 
          #if is_nil(t), do: "unknown", else: Map.get(t, "topic", "unknown") 
        #end)
        %{
          entry: Earmark.as_html!(entry.entry),
          subject: entry.subject,
          date: pd_from_md(entry.date),
          topics: entry.topic
        }
      end)
      keywords = entries |> Enum.reduce([], fn entry, acc -> acc ++ entry.topics end) |> Enum.join(",")
      page_title = case entries do
        [e|_] -> e.subject
        [] -> "A Mustelid"
      end
      description = (keywords |> String.split(",") |> Enum.join(" ")) <> " " <> page_title
      meta_tags = %{description: description, keywords: keywords}
      html = EEx.eval_file(Path.join([eex_base(), "date-entry.eex"]), [meta_tags: meta_tags, meta: meta, entries: entries, title: page_title])
      File.write!(Path.join(dest_base(), "blog/#{Map.get(date_array, idx)}.html"), html)
    end)
  end

  def blog_nothing_found do
    EEx.eval_file(Path.join([eex_base(), "blog-nothing-found.eex"]), [meta_tags: %{},title: "You were reduced to a singularity"])
  end

  def blog_search(term) do
    Mongo.find(:mongo, "entry", 
      %{"$or" => 
        [
          %{"entry" => %{"$regex" => term, "$options" => "$i"}}, 
          %{"subject" => %{"$regex" => term, "$options" => "$i"}}
        ]
      },
      sort: %{"created_at" => -1}) |> 
    Enum.to_list |>
    Enum.map(fn entry ->
      entry |> Utils.normalise_keys |>
      (fn entry ->
        Logger.info "blog_search for #{term} - found: #{entry.subject}"
        matching_lines = entry.entry |> String.split(~r/\n/) |>
        Enum.filter(fn line -> Regex.match?(~r/#{term}/i, line) end) |> Enum.map(fn line ->
          line |> String.split(~r/\s+/) |>
          (fn line_list ->
            if length(line_list) > 20 do
              line_list |> Enum.split_while(fn chunk -> !Regex.match?(~r/#{term}/i, chunk) end) |>
              case do
                {head, tail} ->
                  ["..."] ++
                    Enum.drop(head, (if length(head) < 10, do: 0, else: length(head) - 10)) ++
                      ["<strong>#{List.first(tail)}</strong>"] ++
                        Enum.take(Enum.drop(tail, 1), 10) ++
                          ["..."] |> Enum.join(" ")
                _ -> line_list |> Enum.join(" ")
              end
            else
              line_list |> Enum.map(fn chunk ->
                if Regex.match?(~r/#{term}/i, chunk) do
                  "<strong>#{chunk}</strong>"
                else
                  chunk
                end
              end) |> Enum.join(" ")
            end
          end).()
        end)
        date = pd_from_ut(floor(entry.created_at / 1000), "%a, %d %b, %Y %H:%M")
        link = Timex.from_unix(floor(entry.created_at / 1000)) |> Timex.beginning_of_day |> Timex.to_unix
        entry |> Map.merge(%{date: date, matching_lines: matching_lines, link: "/static/blog/#{link}.html"}) |> Map.drop([:entry])
      end).()
    end) |> (fn entries ->
      html = EEx.eval_file(Path.join([eex_base(), "blog-search.eex"]), [meta_tags: %{}, term: term, entries: entries, title: "Searching for #{term}"])
      html
    end).()
  end

  def poem_index(poems) do
    titles_and_dates = poems |> 
    Enum.sort(fn a, b -> b.fecha < a.fecha end) |> 
    Enum.map(fn p -> p |> Map.take([:title, :normalised_title, :fecha]) end)
    html = EEx.eval_file(Path.join([eex_base(), "poems-index.eex"]), [meta_tags: %{}, poems: titles_and_dates, title: "Mustelidish Poetry"])
    File.write!(Path.join(poems_dest(), "index.html"), html)
  end

  def poem_index_blank do
    html = EEx.eval_file(Path.join([eex_base(), "poems-index-blank.eex"]), [meta_tags: %{}, title: "A bereft universe"])
    File.write!(Path.join(poems_dest(), "index.html"), html)
  end
  
  def poem(p) do
    content = String.split(p.poem, ~r/\n/) |> Enum.join("<br />")
    html = EEx.eval_file(Path.join([eex_base(), "poems.eex"]), [meta_tags: %{}, title: p.title, content: content, date: p.fecha])
    File.write!(Path.join(poems_dest(), "#{p.normalised_title}.html"), html)
  end


  def poems do
    case PoemResolver.all_poems do
      {:ok, poems} ->
        poems |> poem_index
        poems |> Enum.each(&poem/1) 
      _ -> poem_index_blank()
    end
  end

  def link_from_footnote(%{line: line, links: links} = line_with_links, letter, link, text) do
    protocol = case Fuzzyurl.from_string(link) do
      %{protocol: protocol} -> if is_nil(protocol), do: "https", else: protocol
      _ -> "https"
    end
    Regex.split(~r/\[#{letter}\]/, line) |> case do
      [anterior, posterior] -> 
        %{
          line: "#{String.trim(anterior)} #{String.trim(posterior)}",
          links: links ++ [~s[<a href="#{link}">#{text}</a> (#{protocol})]]
        }
      _ -> line_with_links
    end
  end

  def format_footnoted(%{line: line, links: links}) do
    line <> ~s(<div class="text-right" style="font-size: smaller;">) <> Enum.join(links, "<br />") <> "</div>"
  end

  def footnotify(lines_map, footnotes_map) do
    footnotify(lines_map, footnotes_map, 0)
  end
  def footnotify(lines_map, footnotes_map, pointer) do
    if pointer >= length(Map.keys(lines_map)) do
      Map.keys(lines_map) |> 
      Enum.sort(fn a, b -> b < a end) |>
      Enum.reduce([], fn key, res -> 
        case Map.get(lines_map, key) do
          nil -> res
          line -> [format_footnoted(line)|res]
        end
      end)
    else
      # Logger.info "investigando #{Map.get(lines_map, pointer, "--- nothing here ---")}"
      new_footnotes_map = Map.merge(footnotes_map,
        Regex.scan(@reference_re, Map.get(Map.get(lines_map, pointer), :line)) |> 
        Enum.reduce(%{}, fn [_, letter], acc ->
          Map.merge(acc, %{letter => pointer})       
        end))
      new_lines_map = Regex.run(@footnote_re, Map.get(Map.get(lines_map, pointer), :line)) |> case do
        [_, link, letter, text] ->
          case Map.get(footnotes_map, letter, :nulu) do
            :nulu -> lines_map
            idx -> 
              line = Map.get(lines_map, idx)
              Logger.info "reference to this line: #{line.line}"
              lines_map |> 
              Map.merge(%{idx => link_from_footnote(line, letter, link, text)}) |>
              Map.merge(%{pointer => nil})
          end
        _ -> lines_map
      end
      footnotify(new_lines_map, new_footnotes_map, pointer+1)
    end
  end

  def footnotes_to_links(lines_of_gemini) do
    Enum.zip(0..length(lines_of_gemini) |> Enum.to_list, lines_of_gemini |> Enum.map(fn line ->
      %{line: line, links: []}
    end)) |> Enum.into(%{}) |>
    footnotify(%{})
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
  def br(incoming), do: "#{incoming}<br />"
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
    Logger.info "no spaces; #{text}"
    cond do
      Regex.match?(~r/^--+$/, text) -> 
        {:ok, endfn.() |> hr(), :nulu}
      # Regex.match?(~r/^\s*$/, String.trim(text)) ->
        # {:ok, endfn.() |> br(), :nulu}
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
          {:ok, ~s(<a href="#{uri}">#{text}</a>\n)}
        else
          {:ok, ~s(<a href="#{String.replace(uri, ~r/gmi/, "html")}">#{text}</a>\n)}
        end
      _ -> {:error, :invalid}
    end
  end

  def nulu_line(line) do
    case String.split(String.trim(line), ~r/\s+/) do
      arr when length(arr) == 1 -> List.first(arr) |> no_spaces(nuluend())
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
    case String.split(String.trim(line), ~r/\s+/) do
      arr when length(arr) == 1 -> List.first(arr) |> no_spaces(ulend())
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
    case String.split(String.trim(line), ~r/\s+/) do
      arr when length(arr) == 1 -> List.first(arr) |> no_spaces(bqend())
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

  def process_gemini({lines_of_gemini, options}, html_list, status) do
    process_gemini(lines_of_gemini, html_list, status) |> (fn res ->
      {res, options}
    end).()
  end
  def process_gemini([], html_list, status) do
    case process_gemini_line("", status) do
      {:ok, line, _status} -> Enum.reverse([line|html_list])
      _ -> Enum.reverse(html_list)
    end
  end
  def process_gemini([head|tail], html_list, status) do
    case process_gemini_line(head, status) do
      {:ok, line, status} -> process_gemini(tail, [line|html_list], status)
      _ -> process_gemini(tail, html_list, :nulu)
    end
  end

  def pre_optioner({lines_of_gemini, options}) do
    case options do
      %{head_lop: head_lop} -> 
        lines_of_gemini |> Enum.drop(head_lop) |> (fn lines ->
          {lines, Map.delete(options, :head_lop)}
        end).() |> pre_optioner
      %{footnote_links: _} ->
        lines_of_gemini |> footnotes_to_links |> (fn lines ->
          {lines, Map.delete(options, :footnote_links)}
        end).() |> pre_optioner
      _ -> {lines_of_gemini, options}
    end
  end

  def post_optioner({lines_of_html, options}) do
    case options do
      _ -> {lines_of_html, options}
    end
  end

  def gemini_to_html(path, options) do
    case File.read(path) do
      {:ok, file} ->
        {String.split(file, ~r/\n/), options} |> 
        pre_optioner |> 
        process_gemini([], :nulu) |> 
        post_optioner |> 
        (fn {res, _options} ->
          {:ok, Enum.join(res, "\n")}
        end).()
      {:error, error} -> {:error, error}
    end
  end

  def process_gemini_file(relative_path, template, options \\ %{}) do
    gemini_path = Path.join([@gemini_base, relative_path]) <> ".gmi"
    Logger.info "gemini path -> " <> gemini_path
    html_path = Path.join([dest_base(), relative_path]) <> ".html"
    Logger.info "html path -> " <> html_path
    case gemini_to_html(gemini_path, options) do
      {:ok, content} ->
        html = EEx.eval_file(Path.join([eex_base(), "#{template}.eex"]), [meta_tags: %{}, content: content]) 
        File.write!(html_path, html)
      {:error, error} -> {:error, error}
    end
  end

  def process_gemini_dir(dirname) do
    List.last(gemini()) |> IO.inspect
    gemini() |>
    Enum.find(fn t -> t.dir == dirname end) |>
    case do
      %{template: template, geminis: geminis} ->
        geminis |> Enum.each(fn g ->
          Logger.info "processing #{Path.join(dirname, g.file)} with template #{template}"
          process_gemini_file(Path.join(dirname, g.file), template, g.options)
        end)
        :ok
      _ -> {:error, :notfound}
    end
  end
end
