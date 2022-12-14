#!/usr/bin/env elixir

defmodule Cave do
  def display_cave(cave) do
    {minx, maxx} = cave |> Stream.map(&elem(elem(&1, 0), 0)) |> Enum.min_max()
    {miny, maxy} = cave |> Stream.map(&elem(elem(&1, 0), 1)) |> Enum.min_max()

    for y <- miny..maxy do
      for x <- minx..maxx do
        IO.write(List.to_string([Map.get(cave, {x, y}, ?\s)]))
      end

      IO.write("\n")
    end
  end

  def drop({x, maxy}, maxy, _cave), do: {x, maxy}

  def drop({x, y}, maxy, cave) do
    next = [{x, y + 1}, {x - 1, y + 1}, {x + 1, y + 1}] |> Enum.find(&(!cave[&1]))

    cond do
      next ->
        drop(next, maxy, cave)

      y > 0 ->
        {x, y}

      true ->
        nil
    end
  end

  def count_drops(cave) do
    maxy = 1 + (cave |> Stream.map(fn {{_x, y}, _v} -> y end) |> Enum.max())
    count_drops(cave, maxy, 0)
  end

  defp count_drops(cave, maxy, count) do
    boulder = drop({500, 0}, maxy, cave)

    if boulder do
      updated_cave = Map.put(cave, boulder, ?*)
      count_drops(updated_cave, maxy, count + 1)
    else
      {cave, count + 1}
    end
  end
end

File.stream!("input.txt")
|> Stream.map(&String.trim/1)
|> Stream.map(fn line ->
  line
  |> String.split(" -> ")
  |> Stream.map(fn pair ->
    pair
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end)
end)
|> Enum.reduce(%{}, fn line, cave ->
  Stream.chunk_every(line, 2, 1, :discard)
  |> Enum.reduce(cave, fn [{x1, y1}, {x2, y2}], cave ->
    for x <- x1..x2, y <- y1..y2, reduce: cave, do: (cave -> Map.put(cave, {x, y}, ?#))
  end)
end)
|> then(&Cave.count_drops/1)
|> then(fn {_cave, count} ->
  # Cave.display_cave(cave)
  IO.puts(count)
end)
