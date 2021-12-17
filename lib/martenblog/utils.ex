defmodule Martenblog.Utils do
  require Logger
  @anomalous_keys %{"_id" => :id}
  
  def normalise_keys(map) do
    map |> Map.keys |> Enum.reduce(%{}, fn(key, acc) -> cond do
      Enum.member?(Map.keys(@anomalous_keys), key) ->
        Map.merge(acc, %{@anomalous_keys[key] => map[key]})
      true ->
        Map.merge(acc, %{String.to_atom(key) => map[key]})
      end
    end)
  end

  def to_json(map) do
    Poison.Encoder.encode(map, %{}) |> IO.iodata_to_binary
  end

  def rfc2616_now do
    d = DateTime.utc_now
    case Timex.format(d, "%a, %d %b %Y %H:%M:%S GMT", :strftime) do
      {:ok, rfc2616_date} -> rfc2616_date
      _ -> DateTime.to_iso8601(d)
    end
  end

  def randomFilename do
    bubble = ?a..?z
    Enum.map(1..10, fn _-> Enum.random(bubble) end)
  end

  def created_at_to_date(created_at) do
    # Logger.info created_at
    case created_at do
      nil -> "unknown"
      _ -> 
        d = DateTime.from_unix!(Kernel.trunc(created_at / 1000))
        year = Integer.to_string(d.year) |> String.pad_leading(4, "0")
        month = Integer.to_string(d.month) |> String.pad_leading(2, "0")
        day = Integer.to_string(d.day) |> String.pad_leading(2, "0")
        "#{year}-#{month}-#{day}"
    end
  end

  def format_datetime_for_twtxt(dt) do
    year = Integer.to_string(dt.year) |> String.pad_leading(4, "0")
    month = Integer.to_string(dt.month) |> String.pad_leading(2, "0")
    day = Integer.to_string(dt.day) |> String.pad_leading(2, "0")
    hour = Integer.to_string(dt.hour) |> String.pad_leading(2, "0")
    minute = Integer.to_string(dt.minute) |> String.pad_leading(2, "0")
    "#{year}-#{month}-#{day} #{hour}.#{minute} #{dt.zone_abbr}"
  end

end
