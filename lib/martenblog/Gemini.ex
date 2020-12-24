defmodule Martenblog.Gemini do
  require Logger
  alias Martenblog.Topic
  alias Martenblog.Entry
  alias Martenblog.Utils
  @releases_dir "/home/polaris/Elements/flavigula/release/"
  @gemini_public "/usr/share/molly/"
  @gemini_cgi "/usr/share/molly/cgi-bin/"

  def blog_entry_to_gemini(id) do
    Entry.get_entry_by_id(id) |>
    (fn(entry) ->
      filename = "/tmp/#{Utils.randomFilename}"
      File.write!(filename, Map.get(entry, :entry))
      thurk = Port.open(
        {:spawn, "md2gemini -l at-end #{filename}"},
        [:binary]
      )
      topics = Topic.topics_by_ids(Map.get(entry, :topic_ids)) |> 
      Enum.map(fn t -> Map.get(t, "topic") end) |> 
      Enum.join(", ")
      receive do
        {^thurk, {:data, result}} ->
          """
          # #{Map.get(entry, :subject)}
          ## Topics: #{topics}
          ## #{Utils.created_at_to_date(Map.get(entry, :created_at))}

          #{result}

          => gemini://thurk.org/blog/index.gmi tzifur
          => gemini://thurk.org/index.gmi jenju

          @flavigula@sonomu.club
          CC BY-NC-SA 4.0
          """
      end |> (fn text -> File.write!(Path.join(@gemini_public, "blog/#{floor(id)}.gmi"), text) end).()
    end).()
  end

  def make_index(count) do
    Entry.subjects(count) |> Enum.map(fn e ->
      "=> #{Map.get(e, :id)}.gmi #{Map.get(e, :subject)} ( #{Utils.created_at_to_date(Map.get(e, :created_at))} )\n"
    end) |> (fn subject_list ->
      affirmation = """
      # Here lies Martes Flavigula, eternally beneath the splintered earth
      ## Otherwise known as the Martenblog

      => gemini://thurk.org/cgi-bin/martenblog-search.py search
      => gemini://thurk.org/index.gmi tzifur

      #{subject_list}

      => gemini://thurk.org/index.gmi jenju

      @flavigula@sonomu.club

      ### Along with goulish goats and the rippling fen -
      ### these writings 1999-2021 by Bob Murry Shelton are licensed under CC BY-NC-SA 4.0
      """
      File.write!(Path.join(@gemini_public, "blog/index.gmi"), affirmation)
    end).()
  end

  def make_gemini_feed(count) do
    if(count > 53, do: 53, else: count)|>
    Entry.subjects |> Enum.map(fn e ->
      "=> #{Map.get(e, :id)}.gmi #{Utils.created_at_to_date(Map.get(e, :created_at))} - #{Map.get(e, :subject)}\n"
    end) |> (fn subject_list ->
      affirmation = """
      # Martenblog - The musings of a mustelid
      ## Or, here lies Martes Flavigula, eternally beneath the splintered earth

      #{subject_list}

      => gemini://thurk.org/index.html jenju

      @flavigula@sonomu.club

      ### Along with goulish goats and the rippling fen -
      ### these writings 1999-2021 by Bob Murry Shelton are licensed under CC BY-NC-SA 4.0
      """
      File.write!(Path.join(@gemini_public, "blog/feed.gmi"), affirmation)
    end).()
  end

  def slap_um_in(count) do
    make_index(count)
    Entry.subjects(count) |> Enum.each(fn e -> blog_entry_to_gemini(Map.get(e, :id)) end)
  end

  defp join_to_release_dir(thurk) do
    Path.join(@releases_dir, thurk)
  end

  defp unpath(p) do
    Path.basename(p) |> (fn filename -> Regex.scan(~r/^(.+)\..+$/, filename) end).() |> (fn m -> case m do
      [] -> Path.basename(p)
      [[_, name]] -> name
      _ -> Path.basename(p)
    end
    end).()
  end

  defp normalise_title(t) do
    t |> String.trim |> (fn s ->
      case Regex.scan(~r/^(.+)_session.+$/, s) do
        [[_, name]] -> name
        [] -> s
      end
    end).() |> (fn s ->
      case Regex.scan(~r/^\d+[-\s]+(.+)$/, s) do
        [[_, name]] -> name
        [] -> s
      end
    end).() |> (fn s ->
      case Regex.scan(~r/^(.+)-range.*$/, s) do
        [[_, name]] -> name
        [] -> s
      end
    end).() |>
    String.split(~r/[-\s]/) |> Enum.map(fn s -> String.capitalize(s, :default) end) |> Enum.join(" ")
  end

  def release_order_or_ls do
    if File.exists?(join_to_release_dir(".order")) do
      File.read!(join_to_release_dir(".order")) |> String.split(~r/\n/) |> 
      Enum.map(fn t -> String.trim(t) end) |>
      Enum.filter(fn t -> String.length(t) > 0 end) |>
      (fn dir_names -> {:ok, dir_names} end).()
    else
      case File.ls(@releases_dir) do
        {:ok, album_dirs} ->
          {:ok, Enum.reject(album_dirs, fn t -> Regex.match?(~r/^\./, t) end)}
        _ -> {:error, "Nothing found"}
      end
    end
  end

  def releases_main do
    case release_order_or_ls() do
      {:ok, album_dirs} ->
        Enum.map(album_dirs, fn dir -> 
          at = if File.exists?(join_to_release_dir("#{dir}/title")) do
            File.read!(join_to_release_dir("#{dir}/title"))
          else
            dir
          end |> normalise_title
          album_title = "## #{at}\n"
          description = case File.read(join_to_release_dir("#{dir}/description")) do
            {:ok, description} -> "#{description}\n"
            _ -> ""
          end
          date = if File.exists?(join_to_release_dir("#{dir}/date")) do
            d = File.read!(join_to_release_dir("#{dir}/date"))
            "#{d}\n"
          else
            ""
          end
          link = "#{dir}.gmi"
          make_single_release(dir, link, at, description, date)
          "#{album_title}\n#{date}#{description}=> #{link} #{at}\n"
        end)
      _ -> ["# Flavigula Releases\n\n### This space intentionally left to the void."]
    end |> Enum.join("-------------------------------------------------------------------------------\n") |>
    (fn text ->
      argument = """
      # Flavigula Releases
      
      #{text}
      
      => gemini://thurk.org/flavigula/index.gmi tzifur
      => gemini://thurk.org/index.gmi jenju

      @flavigula@sonomu.club
      CC BY-NC-SA 4.0
      """
      File.write!(Path.join(@gemini_public, "flavigula/releases.gmi"), argument)
    end).()
  end

  def releases do
    releases_main()
  end

  def make_single_release(dir, link, album_title, description, date) do
    case File.ls(join_to_release_dir(dir)) do
      {:ok, files} ->
        Enum.reduce(files, %{zip: "", tracks: []}, fn file, acc ->
          if Regex.match?(~r/zip$/, file) do
            Map.merge(acc, %{zip: "release/#{dir}/#{file}"})
          else
            case File.ls(join_to_release_dir("#{dir}/#{file}")) do
              {:ok, tracks} ->
                Enum.reduce(tracks, acc, fn track, acc ->
                  if Regex.match?(~r/(flac|mp3|ogg|wav)$/, track) do
                    Map.merge(acc, %{tracks: ["release/#{dir}/#{file}/#{track}" | Map.get(acc, :tracks)]})
                  else
                    acc
                  end
                end)
              _ -> acc
            end
          end
        end)
      _ -> %{error: "### This album is intentionally part of the void."}
    end |> (fn result ->
      album_body = case result do
        %{error: error} -> error
        %{zip: zip, tracks: tracks} ->
          full_album_text = "=> #{zip} Full Album"
          tracks_text = Enum.reverse(tracks) |>
          Enum.map(fn t -> "=> #{t} #{unpath(t) |> normalise_title}" end) |>
          Enum.join("\n")
          """
          #{tracks_text}
          """
        _ -> "### You have died the flame death, vole"
      end
      argument = """
      # #{album_title}
      ## #{date}

      #{description}

      #{album_body}

      => gemini://thurk.org/flavigula/releases.gmi tzifur
      => gemini://thurk.org/index.gmi jenju

      @flavigula@sonomu.club
      CC BY-NC-SA 4.0
      """
      File.write!(Path.join(@gemini_public, "flavigula/#{link}"), argument)
    end).()
  end

  def releases_old do
    case File.ls("/home/polaris/Elements/flavigula/release") do
      {:ok, album_dirs} ->
        Enum.map(album_dirs, fn dir -> 
          album_title = if File.exists?(join_to_release_dir("#{dir}/title")) do
            File.read!(join_to_release_dir("#{dir}/title"))
          else
            dir
          end |> normalise_title
          description = case File.read(join_to_release_dir("#{dir}/description")) do
            {:ok, description} -> "#{description}\n"
            _ -> ""
          end
          album_header = "\n## #{album_title}\n#{description}"
          case File.ls(join_to_release_dir(dir)) do
            {:ok, files} ->
              Enum.reduce(files, %{zip: "", tracks: []}, fn file, acc ->
                if Regex.match?(~r/zip$/, file) do
                  Map.merge(acc, %{zip: "release/#{dir}/#{file}"})
                else
                  case File.ls(join_to_release_dir("#{dir}/#{file}")) do
                    {:ok, tracks} ->
                      Enum.reduce(tracks, acc, fn track, acc ->
                        if Regex.match?(~r/(flac|mp3|ogg|wav)$/, track) do
                          Map.merge(acc, %{tracks: ["release/#{dir}/#{file}/#{track}" | Map.get(acc, :tracks)]})
                        else
                          acc
                        end
                      end)
                    _ -> acc
                  end
                end
              end)
            _ -> %{ error: "### This album is intentionally part of the void." }
          end |> (fn result ->
            album_body = case result do
              %{error: error} -> error
              %{zip: zip, tracks: tracks} ->
                full_album_text = "=> #{zip} Full Album"
                tracks_text = Enum.reverse(tracks) |> 
                  Enum.map(fn t -> "=> #{t} #{unpath(t) |> 
                  normalise_title}" end) |> Enum.join("\n")
                """
                #{full_album_text}
                #{tracks_text}
                """
              _ -> "### Something has gone terribly wrong, vole"
            end
            "#{album_header}#{album_body}"
          end).()
        end) |> Enum.join("\n")
      _ -> "# Flavigula Releases\n\n### This space intentionally left to the void."
    end |> (fn text -> 
      argument = """
      # Flavigula Releases
      
      #{text}
      
      => gemini://thurk.org/flavigula/index.gmi tzifur
      => gemini://thurk.org/index.gmi jenju"

      @flavigula@sonomu.club
      CC BY-NC-SA 4.0
      """
      File.write!("/home/polaris/src/blizanci/public_gemini/flavigula/releases.gmi", argument) 
    end).()
  end
end
