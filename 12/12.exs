#!/usr/bin/env elixir

defmodule MyMap do
  def expand(points, theend, map) do
    expand(points, theend, map, MapSet.new(), 0)
  end

  def expand(points, theend, map, visited, moves) do
    expansion =
      for point = {x, y} <- points,
          new_point <- [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}],
          !MapSet.member?(visited, new_point),
          h = map[new_point],
          map[point] >= h - 1,
          into: MapSet.new(),
          do: new_point

    if theend in expansion do
      moves + 1
    else
      expand(expansion, theend, map, MapSet.union(visited, expansion), moves + 1)
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

start = Enum.find(points, fn {_, char} -> char == ?S end) |> elem(0)
theend = Enum.find(points, fn {_, char} -> char == ?E end) |> elem(0)

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

MyMap.expand(visited, theend, map)
|> IO.puts()
