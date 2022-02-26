defmodule Martenblog.Rss do
  require Logger
  import XmlBuilder
  alias Martenblog.{Anotacion, Utils}

  def entry_xml(entry) do
    description = case Earmark.as_html(entry.entry) do
      {:ok, html, _} -> html |> HtmlSanitizeEx.basic_html
      _ -> entry.entry
    end
    entry |> (fn entry ->  
      link = entry.date |> Utils.from_mb_to_date_link() |>
        (fn link -> "https://flavigula.net/static/blog/#{link}.html" end).()
      element(:item, [
        element(:title, entry.subject),
        element(:link, link),
        element(:description, description),
        element(:guid, "https://flavigula.net/static/blog/#{link}")
      ])
    end).()
  end 

  def all_entries_xml do
    Anotacion.some(53) |> Enum.to_list |> Enum.map(&Martenblog.Rss.entry_xml/1)
  end 

  def rss do
    channel = [
      element(:title, "Martenblog"),
      element(:link, "https://flavigula.net/#/blog/1"),
      element(:description, "The ramblings of a mustelid (c) Bob Murry Shelton")
    ] ++ all_entries_xml()
    document([
      element(:rss, %{version: "2.0"}, [
        element(:channel, channel)
      ])
    ]) |> generate # |> String.replace(~r/&lt;/, "<", global: true) |> String.replace(~r/&gt;/, ">", global: true) |> String.replace(~r/&quot;/, "\"", global: true)
  end
end 
