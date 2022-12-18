#!/usr/bin/env elixir

defmodule Sensor do
  def dist({x1, y1}, {x2, y2}), do: abs(x1 - x2) + abs(y1 - y2)

  def xses({x1, y1}, {x2, y2}, y) do
    distance = dist({x1, y1}, {x2, y2})
    diff = abs(y - y1)

    if diff > distance do
      []
    else
      [{x1 - (distance - diff), x1 + (distance - diff)}]
    end
  end

  def coverage(ranges) do
    Enum.flat_map(ranges, fn {x1, x2} ->
      [{x1, 1}, {x2 + 1, -1}]
    end)
    |> Enum.sort()
    |> Enum.reduce({0, nil, 0}, fn
      # {x, diff}, {sum, prev_x, height}
      {x, 1}, {sum, _prev_x, 0} -> {sum, x, 1}
      {x, -1}, {sum, prev_x, 1} -> {sum + x - prev_x, nil, 0}
      {_x, diff}, {sum, prev_x, height} -> {sum, prev_x, height + diff}
    end)
    |> elem(0)
  end

  def cannot_b_row(sensors_and_beacons, y) do
    beacons = sensors_and_beacons |> Enum.map(&elem(&1, 1)) |> Enum.uniq()
    beacon_count = beacons |> Enum.count(&(elem(&1, 1) == y)) |> IO.inspect()

    ranges =
      sensors_and_beacons |> Enum.flat_map(fn {sensor, beacon} -> xses(sensor, beacon, y) end)

    coverage(ranges) - beacon_count
  end
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
    |> IO.inspect()

  Sensor.cannot_b_row(sensors_and_beacons, 2_000_000)
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
      assert Sensor.coverage([{2, 4}]) == 3
      assert Sensor.coverage([{1, 10}, {12, 15}]) == 14
      assert Sensor.coverage([{1, 10}, {11, 15}]) == 15
      assert Sensor.coverage([{1, 10}, {10, 15}]) == 15
      assert Sensor.coverage([{1, 10}, {9, 15}]) == 15
      assert Sensor.coverage([{2, 10}, {1, 15}]) == 15
      assert Sensor.coverage([{1, 2}, {1, 3}, {0, 3}, {4, 5}]) == 6

      assert Sensor.coverage([{-651_994, 652_350}, {-264_834, 652_350}, {214_142, 652_350}]) ==
               1_304_345
    end
  end
end
