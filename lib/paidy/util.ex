defmodule Paidy.Util do
  def datetime_from_timestamp(ts) when is_binary ts do
    ts = case Integer.parse ts do
      :error -> 0
      {i, _r} -> i
    end
    datetime_from_timestamp ts
  end

  def datetime_from_timestamp(ts) when is_number ts do
    {{year, month, day}, {hour, minutes, seconds}} = :calendar.gregorian_seconds_to_datetime ts
    {{year + 1970, month, day}, {hour, minutes, seconds}}
  end

  def datetime_from_timestamp(nil) do
    datetime_from_timestamp 0
  end

  def string_map_to_atoms([string_key_map]) do
    string_map_to_atoms string_key_map
  end

  def string_map_to_atoms(string_key_map) do
    for {key, val} <- string_key_map, into: %{}, do: {String.to_atom(key), val}
  end

  @doc ~S"""
    Handle the paidy response

    ## Examples

    iex> Paidy.Util.handle_paidy_response(["test"])
    {:ok, ["test"]}

    iex> Paidy.Util.handle_paidy_response(%{"id" => 123})
    {:ok, %{id: 123}}
  """
  def handle_paidy_response(res) when is_list(res), do: {:ok, res}
  def handle_paidy_response(res) do
    cond do
      res["error"] -> {:error, res}
      res["data"] -> {:ok, Enum.map(res["data"], &Paidy.Util.string_map_to_atoms &1)}
      true -> {:ok, Paidy.Util.string_map_to_atoms res}
    end
  end

  # returns the full response in {:ok, response}
  # this is useful to access top-level properties
  def handle_paidy_full_response(res) do
    cond do
      res["error"] -> {:error, res}
      true -> {:ok, Paidy.Util.string_map_to_atoms res}
    end
  end
end
