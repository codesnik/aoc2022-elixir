#!/usr/bin/env elixir
defmodule TreePatch do
  def transpose(rows) do
    Enum.zip_with(rows, & &1)
  end

  def reverse(rows) do
    Enum.map(rows, &Enum.reverse/1)
  end

  def to_distance(row) do
    row
    |> Enum.with_index()
    |> Enum.map_reduce([], &find_and_update_prevs/2)
    |> then(&elem(&1, 0))
  end

  # doesn't clean conseqeuntive trees of the same height, but that's not a big deal
  def find_and_update_prevs(tree = {height, idx}, prevs) do
    new_prevs = Enum.drop_while(prevs, fn {prev_height, _prev_idx} -> prev_height < height end)

    case new_prevs do
      [] -> {idx, [tree | new_prevs]}
      [{_, prev_idx} | _] -> {idx - prev_idx, [tree | new_prevs]}
    end
  end
end

if System.argv() == [] do
  File.stream!("input.txt")
  |> Stream.map(&String.trim/1)
  |> Enum.map(&String.to_charlist/1)
  |> then(fn rows ->
    # get visibilities for each tree in all directions
    [
      rows
      |> Enum.map(&TreePatch.to_distance/1),
      rows
      |> TreePatch.reverse()
      |> Enum.map(&TreePatch.to_distance/1)
      |> TreePatch.reverse(),
      rows
      |> TreePatch.transpose()
      |> Enum.map(&TreePatch.to_distance/1)
      |> TreePatch.transpose(),
      rows
      |> TreePatch.transpose()
      |> TreePatch.reverse()
      |> Enum.map(&TreePatch.to_distance/1)
      |> TreePatch.reverse()
      |> TreePatch.transpose()
    ]
    # convert matrices to four flat streams for each direction
    |> Enum.map(&Stream.concat/1)
    |> Enum.zip_with(&Enum.product/1)
    |> Enum.max()
  end)
  |> IO.puts()
else
  ExUnit.start()

  defmodule TreeTest do
    use ExUnit.Case

    test "1" do
      data = [[1, 2, 3], [4, 5, 6]]
      assert TreePatch.transpose(data) == [[1, 4], [2, 5], [3, 6]]
      assert TreePatch.transpose(TreePatch.transpose(data)) == data
    end

    test "2" do
      assert TreePatch.to_distance([1, 2, 3]) == [0, 1, 2]
    end

    test "3" do
      assert TreePatch.to_distance([1, 2, 2]) == [0, 1, 1]
    end

    test "4" do
      assert TreePatch.find_and_update_prevs({2, 0}, []) == {0, [{2, 0}]}
    end

    test "5" do
      assert TreePatch.find_and_update_prevs({2, 1}, [{2, 0}]) == {1, [{2, 1}, {2, 0}]}
    end

    test "6" do
      assert TreePatch.find_and_update_prevs({3, 1}, [{2, 0}]) == {1, [{3, 1}]}
    end
  end
end
