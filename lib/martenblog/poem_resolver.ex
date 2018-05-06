defmodule Martenblog.PoemResolver do
  require Logger

  defp poem_from_filename(filename) do
    path = Path.join(Path.expand(Application.get_env(:martenblog, :poem_dir)), filename)
    case File.read(path) do
      {:ok, poem} ->
	# Logger.info "#{poem} good"
	%{:_id => path, filename: path, title: String.slice(filename, 0..-5), poem: poem}
      {:error, e} ->
	# Logger.info "Error: #{e}"
	nil
    end
  end

  def all_poems(_root, _args, _info) do
    path = Path.expand(Application.get_env(:martenblog, :poem_dir))
    poem_filenames = File.ls!(Path.expand(path)) |> Enum.filter(fn(f) -> Regex.match?(~r/\.txt$/, f) end)
    poems = Enum.map(poem_filenames, &poem_from_filename/1) |> Enum.reject(&is_nil/1)
    # IO.inspect poems
    {:ok, poems}
  end
end
