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

  def rfc2616_now do
    d = DateTime.utc_now
    case Timex.format(d, "%a, %d %b %Y %H:%M:%S GMT", :strftime) do
      {:ok, rfc2616_date} -> rfc2616_date
      _ -> DateTime.to_iso8601(d)
    end
  end
end
