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

  def to_json(map) do
    Poison.Encoder.encode(map, %{}) |> IO.iodata_to_binary
  end
end
