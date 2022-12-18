#!/usr/bin/env elixir

defmodule Ls do
  @moduledoc """
    a stupid parser, can only parse numbers up to 99
  """

  def parse([?[ | charlist]) do
    {[], list} = parse(charlist, [])
    list
  end

  def parse([?[ | charlist], list) do
    # recurse
    {new_charlist, sublist} = parse(charlist, [])
    parse(new_charlist, [sublist | list])
  end

  def parse([?] | charlist], list) do
    # return from recursion
    {charlist, Enum.reverse(list)}
  end

  def parse([?, | charlist], list) do
    # skip
    parse(charlist, list)
  end

  def parse([n1, n2 | charlist], list) when n1 in ?0..?9 and n2 in ?0..?9 do
    parse(charlist, [(n1 - ?0) * 10 + (n2 - ?0) | list])
  end

  def parse([n | charlist], list) when n in ?0..?9 do
    parse(charlist, [n - ?0 | list])
  end

  def ordered(a, b) do
    case order(a, b) do
      -1 -> true
      1 -> false
    end
  end

  def order([], [_ | _]), do: -1
  def order([_ | _], []), do: 1
  def order([], []), do: 0

  def order([a | as], [b | bs]) do
    case order(a, b) do
      0 -> order(as, bs)
      other -> other
    end
  end

  def order(a, b) when is_list(a) and not is_list(b), do: order(a, [b])
  def order(a, b) when not is_list(a) and is_list(b), do: order([a], b)

  def order(a, b) do
    cond do
      a < b -> -1
      a == b -> 0
      a > b -> 1
    end
  end
end

if System.argv() == [] do
  list =
    File.stream!("input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.filter(&(&1 != ""))
    |> Stream.map(fn l -> Ls.parse(String.to_charlist(l)) end)
    |> Enum.to_list()
    |> then(fn l -> [[[2]], [[6]] | l] end)
    |> Enum.sort(&Ls.ordered/2)

  idx1 = Enum.find_index(list, &(&1 == [[2]])) + 1
  idx2 = Enum.find_index(list, &(&1 == [[6]])) + 1
  IO.puts(idx1 * idx2)
else
  ExUnit.start()

  defmodule LsTest do
    use ExUnit.Case

    test "sample" do
      assert Ls.ordered([1, 1, 3, 1, 1], [1, 1, 5, 1, 1]) == true
      assert Ls.ordered([[1], [2, 3, 4]], [[1], [4]]) == true
      assert Ls.ordered([[1], [2, 3, 4]], [[1], 4]) == true
      assert Ls.ordered([9], [[8, 7, 6]]) == false
      assert Ls.ordered([[4, 4], 4, 4], [[4, 4], 4, 4, 4]) == true
      assert Ls.ordered([7, 7, 7, 7], [7, 7, 7]) == false
      assert Ls.ordered([], [3]) == true
      assert Ls.ordered([[[]]], [[]]) == false

      assert Ls.ordered([1, [2, [3, [4, [5, 6, 7]]]], 8, 9], [1, [2, [3, [4, [5, 6, 0]]]], 8, 9]) ==
               false
    end
  end
end
