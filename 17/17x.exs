#!/usr/bin/env elixir

defmodule Tetris do
  import Bitwise

  @left_border 0b100_0000
  @right_border 0b000_0001
  @rocks [
    [
      0b0000000,
      0b0000000,
      0b0000000,
      0b0011110
    ],
    [
      0b0000000,
      0b0001000,
      0b0011100,
      0b0001000
    ],
    [
      0b0000000,
      0b0000100,
      0b0000100,
      0b0011100
    ],
    [
      0b0010000,
      0b0010000,
      0b0010000,
      0b0010000
    ],
    [
      0b0000000,
      0b0000000,
      0b0011000,
      0b0011000
    ]
  ]
  @rocks_size 5

  def prepend_space(highest, cave) do
    {highest + 7, [0, 0, 0, 0, 0, 0, 0 | cave]}
  end

  def drop_empty(highest, [0 | cave]), do: drop_empty(highest - 1, cave)
  def drop_empty(highest, cave), do: {highest, cave}

  def fix_rock([f1, f2, f3, f4], [b1, b2, b3, b4 | rest]) do
    [f1 ||| b1, f2 ||| b2, f3 ||| b3, f4 ||| b4 | rest]
  end

  def update_cave(cave, highest, rock, drops) do
    {prefix, rest} = Enum.split(cave, drops)
    drop_empty(highest, prefix ++ fix_rock(rock, rest))
  end

  def move_left(rock, cave) do
    new_rock =
      if Enum.all?(rock, &((@left_border &&& &1) == 0)) do
        Enum.map(rock, &bsl(&1, 1))
      else
        rock
      end

    if free?(new_rock, cave) do
      new_rock
    else
      rock
    end
  end

  def move_right(rock, cave) do
    new_rock =
      if Enum.all?(rock, &((@right_border &&& &1) == 0)) do
        Enum.map(rock, &bsr(&1, 1))
      else
        rock
      end

    if free?(new_rock, cave) do
      new_rock
    else
      rock
    end
  end

  def move_down?(rock, [_skip | cave]), do: free?(rock, cave)

  def free?([f1, f2, f3, f4], [b1, b2, b3, b4 | _]) do
    ((f1 &&& b1) ||| (f2 &&& b2) ||| (f3 &&& b3) ||| (f4 &&& b4)) == 0
  end

  def free?(_, _), do: false

  def display_cave([row | rest]) do
    IO.puts(for n <- 6..0, do: if((row >>> n &&& 1) == 0, do: ?., else: ?#))
    display_cave(rest)
  end

  def display_cave([]), do: IO.puts("")

  def drop_and_update(cave, highest_point, moves_offset, rock_n, moves, memo) do
    rock_idx = rem(rock_n - 1, @rocks_size)
    rock = Enum.at(@rocks, rock_idx)
    {prepended_highest_point, cave} = prepend_space(highest_point, cave)
    {shifted_rock, drops} = drop(cave, rock, moves, moves_offset, 0)

    {new_highest_point, updated_cave} =
      update_cave(cave, prepended_highest_point, shifted_rock, drops)

    moves_idx = rem(moves_offset + drops, :erlang.size(moves))
    cave_top = Enum.take(updated_cave, 500)
    key = {rock_idx, moves_idx, cave_top}

    case Map.get(memo, key) do
      {old_rock_n, old_highest_point} ->
        increments(memo, old_highest_point, old_rock_n, new_highest_point, rock_n)

      nil ->
        updated_memo = Map.put(memo, key, {rock_n, new_highest_point})

        drop_and_update(
          updated_cave,
          new_highest_point,
          moves_offset + drops + 1,
          rock_n + 1,
          moves,
          updated_memo
        )
    end
  end

  def increments(memo, old_highest_point, old_rock_n, new_highest_point, rock_n) do
    big_increment = new_highest_point - old_highest_point
    period = rock_n - old_rock_n
    points = Map.new(Map.values(memo))

    small_increments =
      for(i <- old_rock_n..(rock_n - 1), do: points[i])
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn [a, b] -> b - a end)

    {old_rock_n, period, old_highest_point, big_increment, small_increments}
  end

  def drop(cave_window, rock, moves, moves_offset, drops) do
    move = :binary.at(moves, rem(moves_offset + drops, :erlang.size(moves)))

    rock =
      case move do
        ?< -> move_left(rock, cave_window)
        ?> -> move_right(rock, cave_window)
      end

    if move_down?(rock, cave_window) do
      drop(Enum.drop(cave_window, 1), rock, moves, moves_offset, drops + 1)
    else
      {rock, drops}
    end
  end

  def solve(moves, total) do
    {rock_n, period, highest_point, big_increment, increments} =
      drop_and_update([], 0, 0, 1, moves, %{})

    n = div(total - rock_n, period)
    m = rem(total - rock_n, period)
    highest_point + n * big_increment + Enum.sum(Enum.take(increments, m))
  end
end

moves = File.read!("input.txt") |> String.trim()
total = 1_000_000_000_000

# Tetris.display_cave(cave)
Tetris.solve(moves, total)
|> IO.inspect()
