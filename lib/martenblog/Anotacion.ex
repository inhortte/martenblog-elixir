defmodule Martenblog.Anotacion do
  require Logger
  alias Martenblog.{Tema,Utils}
  @id_re ~r/^id:\s+(\d+)\s*$/
  @subject_re ~r/^[Ss]ubject:\s+(.+)$/
  @date_re ~r/^[Dd]ate:\s+(\d+)\s*$/
  @topic_re ~r/^[Tt]opics?:\s+(.+)$/
  @header_res [id: @id_re, subject: @subject_re, date: @date_re, topic: @topic_re]
  @stasis_dir "/home/polaris/arch-my-hive/martenblog/stasis"

  def get_entry_by_date(d) do
    if File.regular?("#{@stasis_dir}/#{d}_processed.md") do
      md_to_entry(File.read! "#{@stasis_dir}/#{d}_processed.md")
    else
      nil
    end
  end

  def md_to_entry(s) do
    [header | bulk] = String.split(s, ~r/\n{2,}/)
    entry = String.split(header, ~r/\n/) |> Enum.reduce(%{}, fn(line, acc) ->
      Enum.map(Keyword.keys(@header_res), fn key -> 
        {key, Regex.run(@header_res[key], line)}
      end) |> 
        Enum.reject(fn({_, capture}) -> is_nil(capture) end) |>
        Enum.reduce(%{}, fn({key, [_, capture]}, entry) ->
          cap = cond do
            key == :id ->
              with {int, _} <- Integer.parse(capture) do
                int
              else
                _ -> next_entry_id()
              end
            key == :date -> parse_mb_timestamp(capture)
            key == :topic -> capture |> String.split(~r/,/) |> Enum.map(&String.trim/1)
            true -> capture
          end
          Map.merge(acc, %{key => cap})
        end)
      end) |> 
      hashtag_topics(bulk) |> 
      Map.merge(%{entry: bulk |> Enum.join("\n\n")}) |>
      has_id? |>
      has_date?
    entry
  end

  def hashtag_topics(entry, bulk) do
    bulk |> Enum.flat_map(fn line ->
      Regex.scan(~r/#(\w+)\b/, line) |> Enum.map(fn m -> m |> Enum.drop(1) |> List.first |> String.downcase end)
    end) |> 
      (fn h_topics -> (entry.topic ++ h_topics) |> Enum.uniq end).() |>
      (fn topics -> Map.merge(entry, %{topic: topics}) end).()
  end

  def has_id?(entry) do
    if (not Map.has_key?(entry, :id)), do: Map.merge(entry, %{id: next_entry_id()}), else: entry
  end
  
  def has_date?(entry) do
    if (not Map.has_key?(entry, :date)), do: Map.merge(entry, %{date: Utils.now_for_mb()}), else: entry
  end

  def next_entry_id do
    File.ls!(@stasis_dir) |>
      Enum.filter(fn f -> Regex.match?(~r/_processed/, f) end) |>
      Enum.map(fn filename ->
        File.stream!("#{@stasis_dir}/#{filename}", [], :line) |>
          Enum.take(1) |>
          List.first |>
          (fn line -> 
            with [_, id_string] <- Regex.run(~r/id:\s+(\d+)/, line),
              {id, _} <- Integer.parse(id_string) do
              id
            else
              nil -> nil
              :error -> nil
            end
          end).()
      end) |>
      Enum.reject(&is_nil/1) |>
      Enum.sort(fn (a, b) -> a > b end) |>
      List.first |>
      Kernel.+(1)
  end

  def parse_mb_timestamp(ts) do
    case Regex.run(~r/(\d\d\d\d)(\d\d)(\d\d)(\d\d)?(\d\d)?/, ts) do
      [_, _, _, _, _, _] -> ts
      [_, _, _, _] -> "#{ts}0000"
      _ -> Utils.now_for_mb()
    end
  end

  def page(p) do
    File.ls!(@stasis_dir) |>
      Enum.filter(fn f -> Regex.match?(~r/_processed/, f) end) |>
      Enum.sort(&(&1 > &2)) |>
      Enum.drop((p - 1) * 11) |>
      Enum.take(11) |>
      Enum.map(fn filename ->
        File.read!("#{@stasis_dir}/#{filename}") |>
        md_to_entry()
      end)
  end

  def count do
    File.ls!(@stasis_dir) |>
      Enum.filter(fn f -> Regex.match?(~r/_processed/, f) end) |>
      Enum.count
  end
end
