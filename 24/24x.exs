#!/usr/bin/env elixir
defmodule X do
  def read(strmap) do
    map =
      strmap
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(&String.to_charlist/1)

    max_x = length(Enum.at(map, 0)) - 2
    max_y = length(map) - 2

    bzs =
      map
      |> Enum.with_index(-1)
      |> Enum.flat_map(fn {row, y} ->
        row
        |> Enum.with_index(-1)
        |> Enum.flat_map(fn
          {char, x} when char in '<>v^' -> [{{x, y}, [char]}]
          _ -> []
        end)
      end)
      |> Map.new()

    {bzs, max_x, max_y}
  end

  def tick(map, max_x, max_y) do
    for {{x, y}, bzs} <- map,
        bz <- bzs do
      {
        case bz do
          ?v -> {x, rem(y + 1, max_y)}
          ?> -> {rem(x + 1, max_x), y}
          ?< -> {rem(x - 1 + max_x, max_x), y}
          ?^ -> {x, rem(y - 1 + max_y, max_y)}
        end,
        bz
      }
    end
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
  end

  def can_go?(map, max_x, max_y, {x, y}) do
    !(x < 0 ||
        y < 0 ||
        x == max_x ||
        y == max_y ||
        Enum.find_value(Map.get(map, {x, rem(y + 1, max_y)}, []), &(&1 == ?^)) ||
        Enum.find_value(Map.get(map, {rem(x + 1, max_x), y}, []), &(&1 == ?<)) ||
        Enum.find_value(Map.get(map, {rem(x - 1 + max_x, max_x), y}, []), &(&1 == ?>)) ||
        Enum.find_value(Map.get(map, {x, rem(y - 1 + max_y, max_y)}, []), &(&1 == ?v)))
  end

  def wander(map, max_x, max_y, mes, start, theend, n) do
    # IO.puts(n); display(map, max_x, max_y, mes)
    mes =
      for {x, y} <- mes,
          {cx, cy} <- [{x, y}, {x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}],
          cx >= 0,
          cy >= 0,
          cx < max_x,
          cy < max_y,
          can_go?(map, max_x, max_y, {cx, cy}),
          uniq: true,
          do: {cx, cy}

    # starting point or waiting
    mes = [start | mes]

    if theend in mes do
      {tick(map, max_x, max_y), n + 1}
    else
      map = tick(map, max_x, max_y)
      wander(map, max_x, max_y, mes, start, theend, n + 1)
    end
  end

  def display(map, max_x, max_y, mes) do
    for y <- 0..(max_y - 1) do
      for x <- 0..(max_x - 1) do
        if {x, y} in mes,
          do: ?E,
          else:
            (case map[{x, y}] do
               [bz] -> bz
               nil -> ?.
               bzs -> Integer.to_string(length(bzs))
             end)
      end
      |> IO.puts()
    end

    IO.puts("")
  end

  def start(mapstr) do
    {map, max_x, max_y} = read(mapstr)
    {map, n} = wander(map, max_x, max_y, [], {0, -1}, {max_x - 1, max_y - 1}, 0)
    {map, n} = wander(map, max_x, max_y, [], {max_x - 1, max_y - 1}, {0, 0}, n)
    {_map, n} = wander(map, max_x, max_y, [], {0, -1}, {max_x - 1, max_y - 1}, n)
    n + 1
  end
end

File.read!("input.txt")
|> X.start()
|> IO.inspect()
