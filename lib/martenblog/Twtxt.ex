defmodule Martenblog.Twtxt do
  require Logger
  @twtxt_file "/home/polaris/arch-my-hive/twtxt/twtxt.txt"
  @twtxt_gemini_dir "/usr/share/molly/twtxt"

  def read_twtxt_file do
    case File.open(@twtxt_file) do
      {:ok, file} ->
        process_line(file, [], 0, 1)
        {:ok, "oogleboobie!"}
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
        {:ok, "pages created"}
      line ->
        [dt_string, toot] = Regex.split(~r{\s+}, line, parts: 2)
        {:ok, dt, _} = DateTime.from_iso8601(dt_string)
        process_line(file, [{dt, toot}|lines], count+1, page)
    end
  end

  def make_page(lines, page) do
    lines |> Enum.map(fn {dt, txt} ->
      """
      ### #{dt.year}-#{dt.month}-#{dt.day} #{dt.hour}-#{dt.minute}
      #{txt}

      """
    end) |> (fn meat ->
      affirmation = """
      # Martenblog
      ## Twtxt page #{page}

      #{meat}

      => gemini://thurk.org/blog/index.gmi tzifur (Martenblog home)
      => gemini://thurk.org/index.gmi jenju (Thurk.Org home)

      CC BY-NC-SA 4.0
      @flavigula@sonomu.club
      """
      File.write!(Path.join(@twtxt_gemini_dir, "#{page}.gmi"), affirmation)
    end).()
  end
end

