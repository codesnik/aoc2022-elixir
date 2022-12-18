#!/usr/bin/env elixir

defmodule Sensor do
  def dist({x1, y1}, {x2, y2}), do: abs(x1 - x2) + abs(y1 - y2)

  def xses({x1, y1}, {x2, y2}, y) do
    distance = dist({x1, y1}, {x2, y2})
    diff = abs(y - y1)
    r = distance - diff

    if r < 0, do: [], else: [{x1 - r, x1 + r}]
  end

  def find(sensors_and_beacons, yrange, xrange) do
    Enum.find_value(yrange, fn y ->
      ranges =
        sensors_and_beacons
        |> Enum.flat_map(fn {sensor, beacon} -> xses(sensor, beacon, y) end)
        |> Enum.sort()

      x = findx(ranges, xrange)
      x && {x, y}
    end)
  end

  # relies on sorting, x1 always <= x3
  def findx([], r1.._r2), do: r1
  def findx([{x1, _x2} | _], r1.._r2) when r1 < x1, do: r1
  def findx([{_x1, x2} | _], _r1..r2) when r2 <= x2, do: nil
  def findx([{_x1, x2}], _r1..r2) when x2 < r2, do: r2
  def findx([{x1, x2}, {x3, x4} | ranges], range) when x2 + 1 >= x3,
    do: findx([{x1, max(x2, x4)} | ranges], range)

  def findx([{_x1, x2} | ranges], r1..r2) when (x2 + 1) in r1..r2,
    do: findx(ranges, (x2 + 1)..r2)

  def findx([_ | ranges], range), do: findx(ranges, range)
end

if System.argv() == [] do
  sensors_and_beacons =
    "input.txt"
    |> File.stream!()
    |> Stream.map(fn line ->
      [x1, y1, x2, y2] =
        Regex.run(
          ~r/Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)/,
          line,
          capture: :all_but_first
        )
        |> Enum.map(&String.to_integer/1)

      {{x1, y1}, {x2, y2}}
    end)
    |> Enum.to_list()

  {x, y} = Sensor.find(sensors_and_beacons, 0..4_000_000, 0..4_000_000)
  (x*4_000_000 + y)
  |> IO.inspect()
else
  ExUnit.start()

  defmodule SensorTest do
    use ExUnit.Case

    test "distance" do
      assert Sensor.dist({1, 1}, {2, 2}) == 2
      assert Sensor.dist({1, 3}, {1, 0}) == 3
    end

    test "xses" do
      assert Sensor.xses({10, 1}, {10, 2}, 1) == [{9, 11}]
      assert Sensor.xses({10, 1}, {10, 2}, 2) == [{10, 10}]
      assert Sensor.xses({10, 1}, {10, 2}, 3) == []
      assert Sensor.xses({10, 1}, {11, 3}, 2) == [{8, 12}]
    end

    test "coverage" do
      assert Sensor.findx([{1, 10}, {11, 15}], 1..15) == nil
      assert Sensor.findx([{1, 10}, {12, 15}], 2..14) == 11
      assert Sensor.findx([{1, 10}, {10, 14}], 1..15) == 15
      assert Sensor.findx([{1, 10}, {9, 15}],  1..15) == nil
      assert Sensor.findx([{2, 10}, {2, 15}],  1..15) == 1
      assert Sensor.findx([{1, 2}, {1, 3}, {1, 4}, {4, 5}], 1..5) == nil
      assert Sensor.findx([{1, 2}, {4, 5}], 5..6) == 6
    end
  end
end
