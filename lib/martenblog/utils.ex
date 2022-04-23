defmodule Martenblog.Utils do
  require Logger
  alias Plug.Conn.Query
  alias Martenblog.Twtxt
  @anomalous_keys %{"_id" => :id}

  def normalise_keys(nil), do: nil
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

  def format_mb_date(date) do
    case Regex.run(~r/^(\d\d\d\d)(\d\d)(\d\d)$/, String.slice(date, 0, 8)) do
      [_, y, m, d] -> "#{y}-#{m}-#{d}"
      _ -> "the zero"
    end
  end

  def dt_for_mb(dt) do
    [dt.year, dt.month, dt.day, dt.hour, dt.minute] |>
      Enum.map(&to_string/1) |>
      Enum.map(&String.pad_leading(&1, 2, "0")) |>
      Enum.join
  end

  def now_for_mb, do: DateTime.now!("Etc/UTC") |> dt_for_mb

  def elixir_ts_to_date(e_ts), do: js_ts_to_date(e_ts * 1000)
  def js_ts_to_date(ts) do
    ts |> Kernel.trunc |> div(1000) |>
      DateTime.from_unix |> case do
        {:ok, dt} -> dt_for_mb(dt)
        {:error, _} -> now_for_mb()
      end
  end

  def from_mb_to_dt(mb_date) do
    case Timex.parse(mb_date, "{YYYY}{M}{D}{h24}{m}") do
      {:ok, naive} ->
        naive |> DateTime.from_naive!("Etc/UTC")
      _ -> DateTime.now("Etc/UTC")
    end
  end

  def from_full_path_to_dt(path) do
    Regex.run(~r{^[\/\w-]+\/(\d+)_processed.md$}, path) |>
    case do
      [_, mb] -> from_mb_to_dt(mb)
      _ -> DateTime.now("Etc/UTC")
    end
  end

  def from_mb_to_date_link(mb_date) do
    mb_date |> from_mb_to_dt |> Timex.beginning_of_day |> Timex.to_unix
  end

  def subject_from_path(path) do
    File.read!(path) |> String.split("\n", trim: true) |> Enum.find(fn line -> Regex.match?(~r/^[Ss]ubject/, line) end) |> String.split(~r/:/) |> List.last |> String.trim
  end

  def format_datetime_for_twtxt(dt) do
    year = Integer.to_string(dt.year) |> String.pad_leading(4, "0")
    month = Integer.to_string(dt.month) |> String.pad_leading(2, "0")
    day = Integer.to_string(dt.day) |> String.pad_leading(2, "0")
    hour = Integer.to_string(dt.hour) |> String.pad_leading(2, "0")
    minute = Integer.to_string(dt.minute) |> String.pad_leading(2, "0")
    "#{year}-#{month}-#{day} #{hour}.#{minute} #{dt.zone_abbr}"
  end

  def twtxt_query(query_string, hashtag \\ false) do
    query_string |> Query.decode |> Map.get("q") |>
      case do
        nil -> 
          Logger.info "twtxt_query -> There was no query"
          ""
        query ->
          if hashtag do
            Twtxt.read_twtxt_file("##{query}")
          else
            Twtxt.read_twtxt_file(query)
          end |>
          case do
            {:ok, prefix} -> prefix
            {:error, reason} ->
              Logger.error "twtxt_query -> #{reason}"
             ""
          end
      end
  end
end
