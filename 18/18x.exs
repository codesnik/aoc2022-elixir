#!/usr/bin/env elixir
defmodule Steam do
  def expand(steamset, cubeset, xrange, yrange, zrange) do
    expansions =
      for {x, y, z} <- steamset,
          expansion <- [
            {x - 1, y, z},
            {x + 1, y, z},
            {x, y - 1, z},
            {x, y + 1, z},
            {x, y, z - 1},
            {x, y, z + 1}
          ],
          {ex, ey, ez} = expansion,
          ex in xrange,
          ey in yrange,
          ez in zrange,
          !MapSet.member?(steamset, expansion),
          !MapSet.member?(cubeset, expansion),
          into: MapSet.new(),
          do: expansion

    if expansions == MapSet.new() do
      steamset
    else
      expand(MapSet.union(steamset, expansions), cubeset, xrange, yrange, zrange)
    end
  end

  def surface(cubeset) do
    Enum.sum(
      for {x, y, z} <- cubeset do
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
  end
end

cubes =
  File.stream!("input.txt")
  |> Stream.map(&String.trim/1)
  |> Enum.map(fn line ->
    line |> String.split(",") |> Enum.map(&String.to_integer/1) |> List.to_tuple()
  end)

cubeset = for cube <- cubes, into: MapSet.new(), do: cube

{minx, maxx} = Enum.min_max(Enum.map(cubes, &elem(&1, 0)))
{miny, maxy} = Enum.min_max(Enum.map(cubes, &elem(&1, 1)))
{minz, maxz} = Enum.min_max(Enum.map(cubes, &elem(&1, 2)))

xrange = (minx - 1)..(maxx + 1)
yrange = (miny - 1)..(maxy + 1)
zrange = (minz - 1)..(maxz + 1)

startsteam = MapSet.new([{minx - 1, miny - 1, minz - 1}])
steamset = Steam.expand(startsteam, cubeset, xrange, yrange, zrange)

w = Range.size(xrange)
l = Range.size(yrange)
h = Range.size(zrange)

# cubesurface = Steam.surface(cubeset)
steamsurface = Steam.surface(steamset)

(steamsurface - 2 * (w * l + w * h + l * h))
|> IO.puts()
