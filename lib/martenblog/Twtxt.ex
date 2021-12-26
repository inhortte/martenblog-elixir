defmodule Martenblog.Twtxt do
  require Logger
  alias Martenblog.Utils
  @twtxt_file "/home/polaris/arch-my-hive/twtxt/twtxt.txt"
  @twtxt_gemini_dir "/usr/share/molly/twtxt"

  def read_twtxt_file(filter) do
    clean_dir(filter)
    case File.open(@twtxt_file) do
      {:ok, file} ->
        process_line(file, [], 0, 1, filter)
      {:error, _} ->
        Logger.error "#{@twtxt_file} not found"
        {:error, "file not found"}
    end
  end

  def process_line(file, lines, count, page, filter) when count >= 37 do 
    make_page(lines, page, filter)
    process_line(file, [], 0, page+1, filter)
  end
  def process_line(file, lines, count, page, filter) do
    case IO.binread(file, :line) do
      {:error, reason} ->
        make_page(lines, page, filter)
        {:error, reason}
      :eof ->
        make_page(lines, page, filter)
        organise_dir(filter)
      line ->
        line |> filter_line(filter) |> 
          assimilate_line(file, lines, count, page, filter)
    end
  end

  def filter_line(line, filter) do
    case is_nil(filter) do
      true -> line
      false -> 
        if Regex.match?(~r/#{filter}/, line), do: line, else: nil
    end
  end

  def assimilate_line(line, file, lines, count, page, filter) do
    case is_nil(line) do
      true -> process_line(file, lines, count, page, filter)
      false -> 
        [dt_string, toot] = Regex.split(~r{\s+}, line, parts: 2)
        {:ok, dt, _} = DateTime.from_iso8601(dt_string)
        process_line(file, [{dt, toot}|lines], count+1, page, filter)
    end
  end

  def make_page([], _, filter), do: organise_dir(filter)
  def make_page(lines, page, filter) do
    prefix = filter |> make_prefix
    lines |> Enum.map(fn {dt, txt} ->
      """
      ### #{Utils.format_datetime_for_twtxt(dt)}
      #{txt}

      """
    end) |> (fn meat ->
      search_link = "=> gemini://thurk.org/cgi-bin/twtxt-search.py Search the twtxt\n" 
      search_info = if is_nil(filter) do
        ""
      else
        "### Search results for '#{filter}'\n=> tw1.gmi tzifur (back)\n"
      end
      affirmation = """
      # Martenblog
      :::pagina:::
      #{search_link}
      #{search_info}
      #{meat}

      => gemini://thurk.org/index.gmi jenju (Thurk.Org home)

      CC BY-NC-SA 4.0
      @flavigula@sonomu.club
      """
      File.write!(Path.join(@twtxt_gemini_dir, "#{page}MBTWTXT#{prefix}.gmi"), affirmation)
    end).()
  end

  def make_prefix(s) do
    case is_nil(s) do
      true -> ""
      false -> 
        prefix = :crypto.hash(:sha256, :erlang.term_to_binary(s)) |> Base.encode16
        :ets.insert(:searches, {:hash, prefix})
        prefix
    end
  end

  def clean_dir(filter) do
    prefix = make_prefix(filter)
    case File.ls(@twtxt_gemini_dir) do
      {:error, reason} ->
        Logger.error "Does #{@twtxt_gemini_dir} exist? #{reason}"
      {:ok, files} ->
        files |> Enum.each(fn filename ->
          if Regex.match?(~r{^\d+#{prefix}\.gmi$}, filename) do
            File.rm(Path.join(@twtxt_gemini_dir, filename))
          end
        end)
    end
  end

  def organise_dir(filter) do
    case File.ls(@twtxt_gemini_dir) do
      {:error, reason} ->
        Logger.error "Does #{@twtxt_gemini_dir} exist? #{reason}"
        {:error, reason}
      {:ok, files} ->
        prefix = make_prefix(filter)
        files |> Enum.filter(fn filename ->
          Regex.match?(~r{^\d+MBTWTXT#{prefix}\.gmi$}, filename)
        end) |>
          Enum.sort(fn f1, f2 ->
            {i1, _} = :string.to_integer(f1)
            {i2, _} = :string.to_integer(f2)
            i2 <= i1
          end) |>
          Enum.with_index(1) |> 
          (fn files ->
            # Logger.info "organise_dir -> #{inspect files}"
            Enum.each(files, fn {filename, idx} ->
              adjust_file(filename, idx, length(files))
            end)
            {:ok, prefix}
          end).()
    end
  end

  def adjust_file(filename, idx, count) do
    [_, _page, hash] = Regex.run(~r{^(\d+)MBTWTXT(.*)\.gmi$}, filename)
    Logger.info "adjust_file -> hash is #{hash} and filename is #{filename}"
    File.open!(Path.join(@twtxt_gemini_dir, filename), [:read]) |>
      adjust_line(idx, [], count) |>
      (fn lines ->
        affirmation_of_my_faith_in_baal = """
        #{lines}
        """
        hash_part = if String.length(hash) > 0, do: "-#{hash}", else: ""
        File.write!(
          Path.join(@twtxt_gemini_dir, "tw#{idx}#{hash_part}.gmi"),
          affirmation_of_my_faith_in_baal
        )
        File.rm(Path.join(@twtxt_gemini_dir, filename))
      end).()
  end

  def adjust_line(file, idx, lines, count) do
    case IO.binread(file, :line) do
      {:error, error} -> 
        Logger.error "adjust_line -> #{error}"
        adjust_line(file, idx, lines, count)
      :eof ->
        Enum.reverse(lines)
      line ->
        if Regex.match?(~r{:::pagina:::}, line) do
          previous_page = if idx > 1 do
            "=> tw#{idx-1}.gmi funolu (previous)\n"
          else
            ""
          end
          next_page = if idx < count do
            "=> tw#{idx+1}.gmi potonolu (next)\n"
          else
            ""
          end
          affirmation = "#{previous_page}Twtxt #{idx}\n#{next_page}"
          adjust_line(file, idx, [affirmation|lines], count)
        else
          new_line = if Regex.match?(~r{^\s+#}, line) do
            String.trim_leading(line)
          else
            line
          end
          adjust_line(file, idx, [new_line|lines], count)
        end
    end
  end
end

