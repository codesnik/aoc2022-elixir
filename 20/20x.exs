#!/usr/bin/env elixir

defmodule Mixing do
  def norm(n, l) do
    new_n = rem(n, l - 1)
    if new_n < 0, do: new_n + l - 1, else: new_n
  end

  def move(nums) do
    l = length(nums)
    nums = Enum.with_index(nums)
    moved_nums = for _ <- 1..10, i <- 0..(l - 1), reduce: nums, do: (nums -> move(nums, i, l))
    Enum.map(moved_nums, &elem(&1, 0))
  end

  def move(nums, i, l) do
    # this is wasteful, but should work
    pos = Enum.find_index(nums, &(elem(&1, 1) == i))

    {pref, [pair = {n, _} | post]} = Enum.split(nums, pos)
    new_pos = norm(pos + n, l)

    cond do
      new_pos < pos ->
        {new_pref, new_post} = Enum.split(pref, new_pos)
        new_pref ++ [pair] ++ new_post ++ post

      new_pos > pos ->
        {new_pref, new_post} = Enum.split(post, new_pos - pos)
        pref ++ new_pref ++ [pair] ++ new_post

      new_pos == pos ->
        pref ++ [pair] ++ post
    end
  end

  def find_after_zero(nums, ns) do
    zero = Enum.find_index(nums, &(&1 == 0))
    l = length(nums)
    ns |> Enum.map(&Enum.at(nums, rem(zero + &1, l)))
  end
end

if System.argv() != ["test"] do
  nums =
    "input.txt"
    |> File.stream!()
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(&(&1 * 811_589_153))

  # IO.inspect nums
  mixed = Mixing.move(nums)

  Mixing.find_after_zero(mixed, [1000, 2000, 3000])
  |> Enum.sum()
  |> IO.inspect()
else
  ExUnit.start()

  defmodule MixingTest do
    use ExUnit.Case

    test "norm" do
      assert Mixing.norm(0 + 1, 4) == 1
      assert Mixing.norm(0 + 5, 4) == 2
      assert Mixing.norm(2 + 1, 4) == 0
      assert Mixing.norm(3 + 1, 4) == 1
      assert Mixing.norm(0 - 1, 4) == 2
      assert Mixing.norm(3 - 1, 4) == 2
    end

    test "sample" do
      # it rotates the buffer, but so what
      assert Mixing.move([1, 2, -3, 3, -2, 0, 4]) == [-2, 1, 2, -3, 4, 0, 3]
    end
  end
end
