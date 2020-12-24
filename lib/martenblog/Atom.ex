defmodule Martenblog.Atom do
  import XmlBuilder
  alias Martenblog.Utils
  alias Martenblog.Entry

  def entry_xml(entry) do
    # content = Map.get(entry, "entry")
    content = case Earmark.as_html(Map.get(entry, "entry")) do
      {:ok, html, _} -> html |> HtmlSanitizeEx.basic_html
      _ -> Map.get(entry, "entry")
    end
    entry |> (fn entry ->
      title = Map.get(entry, "subject")
      modified = Map.get(entry, "created_at") |> (fn dt ->
        dt / 1000 |> Kernel.trunc |> DateTime.from_unix! |> DateTime.to_iso8601()
      end).()
      id = "gemini://thurk.org/blog/#{Map.get(entry, "_id") |> Kernel.trunc}.gemini"
      link = "gemini://thurk.org/blog/#{Kernel.trunc(Map.get(entry, "_id"))}.gemini"
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
    Mongo.find(:mongo, "entry", %{}, [sort: [created_at: -1], limit: c]) |> Enum.to_list |> Enum.map(&Martenblog.Atom.entry_xml/1)
  end

  def all_entries_xml do
    Mongo.find(:mongo, "entry", %{}, [sort: [created_at: -1]]) |> Enum.to_list |> Enum.map(&Martenblog.Atom.entry_xml/1)
  end

  def atom do
    title = "Martenblog"
    link1 = "gemini://thurk.org/blog/index.gemini"
    link2 = "https://flavigula.net/#/blog/1"
    modified = Entry.latest_entry |> Map.get("created_at") |> (fn dt ->
      dt / 1000 |> Kernel.trunc |> DateTime.from_unix! |> DateTime.to_iso8601()
    end).()
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
end
