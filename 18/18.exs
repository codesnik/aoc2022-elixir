#!/usr/bin/env elixir
cubes =
  File.stream!("input.txt")
  |> Stream.map(&String.trim/1)
  |> Enum.map(fn line ->
    line |> String.split(",") |> Enum.map(&String.to_integer/1) |> List.to_tuple
  end)

cubeset = for cube <- cubes, into: MapSet.new(), do: cube

Enum.sum(
  for {x, y, z} <- cubes do
    6 -
      Enum.count(
        [
          {x - 1, y, z},
          {x + 1, y, z},
          {x, y - 1, z},
          {x, y + 1, z},
          {x, y, z - 1},
          {x, y, z + 1}
        ],
        &MapSet.member?(cubeset, &1)
      )
  end
)
|> IO.puts()
