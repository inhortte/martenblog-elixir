defmodule Martenblog.Atom do
  import XmlBuilder
  require Logger
  alias Martenblog.{Utils, Anotacion}
  @twtxt_file "/home/polaris/arch-my-hive/twtxt/twtxt.txt"

  def entry_xml(entry) do
    content = case Earmark.as_html(entry.entry) do
      {:ok, html, _} -> html |> HtmlSanitizeEx.basic_html
      _ -> entry.entry
    end
    entry |> (fn entry ->
      title = entry.subject
      modified = entry.date |> Utils.from_mb_to_dt |> DateTime.to_iso8601()
      id = "gemini://thurk.org/blog/#{entry.id |> Kernel.trunc()}.gmi"
      link = "gemini://thurk.org/blog/#{entry.id |> Kernel.trunc()}.gmi"
      element(:entry, [
        element(:title, title),
        element(:id, id),
        element(:link, %{href: link}),
        element(:summary, content),
        element(:updated, modified)
      ])
    end).()
  end

  def entries_xml(c) do
    Anotacion.some(c) |> Enum.to_list |> Enum.map(&Martenblog.Atom.entry_xml/1)
  end

  def all_entries_xml do
    Anotacion.all |> Enum.to_list |> Enum.map(&Martenblog.Atom.entry_xml/1)
  end

  def atom do
    title = "Martenblog"
    link1 = "gemini://thurk.org/blog/index.gmi"
    link2 = "https://flavigula.net/static/blog/page_1.html"
    modified = Anotacion.latest_mb_date |> Utils.from_mb_to_dt |> DateTime.to_iso8601()
    document([
      element(:feed, %{xmlns: "http://www.w3.org/2005/Atom"}, [
        element(:title, title),
        element(:id, "gemini://thurk.org/blog/feed"),
        element(:author, [ element(:name, "Bob Murry Shelton") ]),
        element(:link, %{rel: "alternate", type: "text/gemini", href: link1}),
        element(:link, %{rel: "alternate", type: "text/html", href: link2}),
        element(:updated, modified),
        entries_xml(53)
      ])
    ]) |> generate #  |> String.replace(~r/&lt;/, "<", global: true) |> String.replace(~r/&gt;/, ">", global: true) |> String.replace(~r/&quot;/, "\"", global: true)
  end

  def twtxt_element({dt, toot}) do
    modified = dt |> DateTime.to_iso8601
    title = toot |> String.split(~r/\s+/) |> Enum.take(5) |> Enum.join(" ")
    id = "gemini://thurk.org/twtxt/#{String.slice(toot, 0, 10) |> String.replace(~r/\s+/, "")}"
    link = "gemini://thurk.org/twtxt/tw1.gmi"
    element(:entry, [
      element(:id, id),
      element(:title, title),
      element(:link, %{href: link}),
      element(:summary, toot),
      element(:updated, modified)
    ])
  end

  def twtxt_atom(toots) do
    title = "Flavigula  Twtxt"
    link = "gemini://thurk.org/twtxt/tw1.gmi"
    modified = List.first(toots) |> Tuple.to_list |> List.first |> DateTime.to_iso8601
    document([
      element(:feed, %{xmlns: "http://www.w3.org/2005/Atom"}, [
        element(:title, title),
        element(:id, "gemini://thurk.org/twtxt/tw1.gmi"),
        element(:author, [ element(:name, "Bob Murry Shelton") ]),
        element(:link, %{rel: "alternate", type: "text/gemini", href: link}),
        element(:updated, modified),
        Enum.map(toots, &Martenblog.Atom.twtxt_element/1)
      ])
    ]) |> generate
  end

  def twtxts do
    case File.open(@twtxt_file, [:read]) do
      {:ok, file } ->
        process_twtxt_line(file, [])
      {:error, _} ->
        Logger.error "#{@twtxt_file} not found"
        twtxt_atom([])
    end
  end

  def process_twtxt_line(_file, toots) when length(toots) >= 101, do: twtxt_atom(toots)
  def process_twtxt_line(file, toots) do
    case IO.binread(file, :line) do
      {:error, _reason} -> twtxt_atom(toots)
      :eof -> twtxt_atom(toots)
      line -> assimilate_line(file, line, toots)
    end
  end

  def assimilate_line(file, line, toots) do
    case is_nil(line) do
      true -> process_twtxt_line(file, toots)
      false -> 
        [dt_string, toot] = Regex.split(~r{\s+}, line, parts: 2)
        {:ok, dt, _} = DateTime.from_iso8601(dt_string)
        process_twtxt_line(file, [{dt, toot}|toots])
    end
  end
end
