#!/usr/bin/env elixir

defmodule Rope do
  def shift_tail({hx, hy}, {tx, ty}) when abs(tx - hx) > 1 or abs(ty - hy) > 1 do
    {shift_towards(tx, hx), shift_towards(ty, hy)}
  end

  def shift_tail(_, coords), do: coords

  defp shift_towards(a, b) when a < b, do: a + 1
  defp shift_towards(a, b) when a > b, do: a - 1
  defp shift_towards(a, _), do: a
end

if System.argv() == [] do
  File.stream!("input.txt")
  |> Stream.map(&String.split/1)
  |> Stream.flat_map(fn [command, count] -> for _ <- 1..String.to_integer(count), do: command end)
  |> Enum.scan({0, 0}, fn command, {hx, hy} ->
    case command do
      "U" -> {hx, hy - 1}
      "D" -> {hx, hy + 1}
      "L" -> {hx - 1, hy}
      "R" -> {hx + 1, hy}
    end
  end)
  |> then(fn coords -> [{0, 0} | coords] end)
  |> Enum.scan(&Rope.shift_tail/2)
  |> Enum.scan(&Rope.shift_tail/2)
  |> Enum.scan(&Rope.shift_tail/2)
  |> Enum.scan(&Rope.shift_tail/2)
  |> Enum.scan(&Rope.shift_tail/2)
  |> Enum.scan(&Rope.shift_tail/2)
  |> Enum.scan(&Rope.shift_tail/2)
  |> Enum.scan(&Rope.shift_tail/2)
  |> Enum.scan(&Rope.shift_tail/2)
  |> Enum.uniq()
  |> Enum.count()
  |> IO.puts()
else
  ExUnit.start()

  defmodule RopeTest do
    use ExUnit.Case

    test "1" do
      assert Rope.shift_tail({1, 0}, {0, 0}) == {0, 0}
    end

    test "2" do
      assert Rope.shift_tail({2, 0}, {0, 0}) == {1, 0}
    end

    test "3" do
      assert Rope.shift_tail({-2, -1}, {0, 0}) == {-1, -1}
    end
  end
end
