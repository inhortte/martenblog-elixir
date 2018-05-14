defmodule Martenblog.PoemResolver do
  require Logger

  defp normalise_title(title) do
    String.downcase(title) |> String.replace(~r/[\s'"]+/, "-")    
  end

  def poem_from_filename(filename) do
    path = Path.join(Path.expand(Application.get_env(:martenblog, :poem_dir)), filename)
    Logger.info "filename: #{filename}"
    case File.read(path) do
      {:ok, conglomerate} ->
	conglomerate_re = ~r<^(.+)\n([-\d]+)\n-+\n(.+)$>s
	IO.puts "conglomerate: #{conglomerate}"
	match = Regex.run(conglomerate_re, conglomerate)
	IO.puts "match:"
	IO.inspect match
	if is_nil(match) do
	  nil
	else
	  {_, title, fecha, poem} = List.to_tuple(match)
	  %{:_id => path, filename: path, title: title, fecha: fecha, poem: poem, normalised_title: normalise_title(title)}
	end
      {:error, e} ->
	Logger.info "Error: #{e}"
	nil
    end
  end

  def all_poems(_root, _args, _info) do
    path = Path.expand(Application.get_env(:martenblog, :poem_dir))
    poem_filenames = File.ls!(Path.expand(path)) |> Enum.filter(fn(f) -> Regex.match?(~r/\.txt$/, f) end)
    poems = Enum.map(poem_filenames, &poem_from_filename/1) |> Enum.reject(&is_nil/1)
    # IO.inspect poems
    {:ok, Enum.sort(poems, &(Map.get(&1, "fecha") >= Map.get(&2, "fecha")))}
  end
end
