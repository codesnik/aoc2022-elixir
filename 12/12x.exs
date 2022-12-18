#!/usr/bin/env elixir

defmodule MyMap do
  def expand(points, theends, map) do
    expand(points, theends, map, MapSet.new(), 0)
  end

  def expand(points, theends, map, visited, moves) do
    expansion =
      for point = {x, y} <- points,
          new_point <- [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}],
          !MapSet.member?(visited, new_point),
          h = map[new_point],
          map[point] - h <= 1,
          into: MapSet.new(),
          do: new_point

    if Enum.any?(expansion, fn point -> point in theends end) do
      moves + 1
    else
      expand(expansion, theends, map, MapSet.union(visited, expansion), moves + 1)
    end
  end
end

points =
  "input.txt"
  |> File.stream!()
  |> Stream.map(&String.trim/1)
  |> Stream.map(&String.to_charlist/1)
  |> Stream.with_index()
  |> Stream.flat_map(fn {chars, y} ->
    Enum.with_index(chars) |> Enum.map(fn {char, x} -> {{x, y}, char} end)
  end)

theends =
  Enum.filter(points, fn {_, char} -> char in 'Sa' end)
  |> Enum.map(&elem(&1, 0))
  |> MapSet.new()

start = Enum.find(points, fn {_, char} -> char == ?E end) |> elem(0)

map =
  Stream.map(points, fn {coords, char} ->
    {coords,
     case char do
       ?S -> ?a
       ?E -> ?z
       _ -> char
     end}
  end)
  |> Map.new()

visited = MapSet.new([start])

MyMap.expand(visited, theends, map)
|> IO.puts()
