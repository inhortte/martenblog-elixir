defmodule Martenblog.Twtxt do
  require Logger
  alias Martenblog.Utils
  @twtxt_file "/home/polaris/arch-my-hive/twtxt/twtxt.txt"
  @twtxt_gemini_dir "/usr/share/molly/twtxt"

  def read_twtxt_file do
    clean_dir()
    case File.open(@twtxt_file) do
      {:ok, file} ->
        process_line(file, [], 0, 1)
      {:error, _} ->
        Logger.error "#{@twtxt_file} not found"
        {:error, "file not found"}
    end
  end

  def process_line(file, lines, count, page) when count >= 37 do 
    make_page(lines, page)
    process_line(file, [], 0, page+1)
  end
  def process_line(file, lines, count, page) do
    case IO.read(file, :line) do
      {:error, reason} ->
        make_page(lines, page)
        {:error, reason}
      :eof ->
        make_page(lines, page)
        organise_dir()
      line ->
        [dt_string, toot] = Regex.split(~r{\s+}, line, parts: 2)
        {:ok, dt, _} = DateTime.from_iso8601(dt_string)
        process_line(file, [{dt, toot}|lines], count+1, page)
    end
  end

  def make_page([], _), do: organise_dir()
  def make_page(lines, page) do
    lines |> Enum.map(fn {dt, txt} ->
      """
      ### #{Utils.format_datetime_for_twtxt(dt)}
      #{txt}

      """
    end) |> (fn meat ->
      affirmation = """
      # Martenblog
      :::pagina:::

      #{meat}

      => gemini://thurk.org/blog/index.gmi tzifur (Martenblog home)
      => gemini://thurk.org/index.gmi jenju (Thurk.Org home)

      CC BY-NC-SA 4.0
      @flavigula@sonomu.club
      """
      File.write!(Path.join(@twtxt_gemini_dir, "#{page}.gmi"), affirmation)
    end).()
  end

  def clean_dir do
    case File.ls(@twtxt_gemini_dir) do
      {:error, reason} ->
        Logger.error "Does #{@twtxt_gemini_dir} exist? #{reason}"
      {:ok, files} ->
        files |> Enum.each(fn filename ->
          if Regex.match?(~r{^\d+\.gmi$}, filename) do
            File.rm(Path.join(@twtxt_gemini_dir, filename))
          end
        end)
    end
  end

  def organise_dir do
    case File.ls(@twtxt_gemini_dir) do
      {:error, reason} ->
        Logger.error "Does #{@twtxt_gemini_dir} exist? #{reason}"
        {:error, reason}
      {:ok, files} ->
        files |> Enum.filter(fn filename ->
          Regex.match?(~r{^\d+\.gmi$}, filename)
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
            {:ok, "oogleboobie!"}
          end).()
    end
  end

  def adjust_file(filename, idx, count) do
    File.open!(Path.join(@twtxt_gemini_dir, filename), [:read]) |>
      adjust_line(idx, [], count) |>
      (fn lines ->
        affirmation_of_my_faith_in_baal = """
        #{lines}
        """
        File.write!(
          Path.join(@twtxt_gemini_dir, "tw#{idx}.gmi"),
          affirmation_of_my_faith_in_baal
        )
        File.rm(Path.join(@twtxt_gemini_dir, filename))
      end).()
  end

  def adjust_line(file, idx, lines, count) do
    case IO.read(file, :line) do
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

