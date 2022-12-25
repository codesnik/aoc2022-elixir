#!/usr/bin/env elixir

defmodule X do
  def read_map(string) do
    map =
      string
      |> String.trim_trailing()
      |> String.split("\n")
      |> Enum.map(&String.to_charlist/1)

    xranges =
      map
      |> Enum.map(fn row ->
        orig_length = length(row)
        shift = length(Enum.take_while(row, fn x -> x == ?\s end))
        shift..(orig_length - 1)
      end)

    max_y = length(map) - 1
    max_x = Enum.max(for _..x2 <- xranges, do: x2)

    reversed_xranges = Enum.reverse(xranges)

    yranges =
      for x <- 0..max_x do
        y1 = Enum.find_index(xranges, &(x in &1))
        y2 = max_y - Enum.find_index(reversed_xranges, &(x in &1))
        y1..y2
      end

    {map, to_map(xranges), to_map(yranges)}
  end

  def to_map(list) do
    list |> Enum.with_index() |> Enum.map(fn {x, i} -> {i, x} end) |> Map.new()
  end

  def map_at({x, y}, map) do
    map |> Enum.at(y) |> Enum.at(x)
  end

  def inc(x, minx..maxx) when (x + 1) in minx..maxx, do: x + 1
  def inc(_x, minx.._), do: minx

  def dec(x, minx..maxx) when (x - 1) in minx..maxx, do: x - 1
  def dec(_x, _..maxx), do: maxx

  def start_walk({map, xranges, yranges}, moves) do
    start_x.._ = xranges[0]
    start_coords = {start_x, 0}

    Enum.reduce(moves, start_coords, fn
      0, {x, y} ->
        new_x = inc(x, xranges[y])
        if map_at({new_x, y}, map) == ?#, do: {x, y}, else: {new_x, y}

      1, {x, y} ->
        new_y = inc(y, yranges[x])
        if map_at({x, new_y}, map) == ?#, do: {x, y}, else: {x, new_y}

      2, {x, y} ->
        new_x = dec(x, xranges[y])
        if map_at({new_x, y}, map) == ?#, do: {x, y}, else: {new_x, y}

      3, {x, y} ->
        new_y = dec(y, yranges[x])
        if map_at({x, new_y}, map) == ?#, do: {x, y}, else: {x, new_y}
    end)
  end

  def parse_moves(moves, facing) do
    String.to_charlist(String.trim(moves))
    |> Enum.chunk_by(fn x -> x in ?0..?9 end)
    |> Enum.map(&List.to_string/1)
    |> Enum.reduce({facing, []}, fn
      "L", {facing, moves} ->
        {rem(facing + 3, 4), moves}

      "R", {facing, moves} ->
        {rem(facing + 1, 4), moves}

      n, {facing, moves} ->
        n = String.to_integer(n)
        {facing, for(_ <- 1..n, do: facing) ++ moves}
    end)
    |> then(fn {facing, moves} -> {facing, Enum.reverse(moves)} end)
  end
end

[mapstr, directions] =
  "input.txt"
  |> File.read!()
  |> String.split("\n\n")

{facing, moves} = X.parse_moves(directions, 0)
{x, y} = X.start_walk(X.read_map(mapstr), moves)
# {facing, x, y} |> IO.inspect
IO.puts(1000 * (y + 1) + 4 * (x + 1) + facing)
