defmodule Martenblog.Rss do
  require Logger
  import XmlBuilder
  alias Martenblog.Entry
  alias Martenblog.BlogResolver

  def entry_xml(entry) do
    entry |> (fn entry ->  
      id = Map.get(entry, "_id")
      link = BlogResolver.yearMonthDay(entry) |> (fn ymd -> "https://flavigula.net/#/blog/#{ymd.year}/#{ymd.month}/#{ymd.day}" end).()
      element(:item, [
        element(:title, Map.get(entry, "subject")),
        element(:link, link),
        element(:description, Map.get(entry, "entry")),
        element(:guid, "https://flavigula.net/#/blog/entry/#{Kernel.trunc(id)}")
      ])
    end).()
  end 

  def all_entries_xml do
    Mongo.find(:mongo, "entry", %{}, [sort: [created_at: -1]]) |> Enum.to_list |> Enum.map(&Martenblog.Rss.entry_xml/1)
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
    ]) |> generate
  end
end 
