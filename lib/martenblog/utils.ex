defmodule Martenblog.Utils do
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
end
