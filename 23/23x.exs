#!/usr/bin/env elixir

defmodule E do
  def read(str) do
    String.trim(str)
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.flat_map(fn {l, y} ->
      String.to_charlist(l)
      |> Enum.with_index()
      |> Enum.flat_map(fn
        {?#, x} -> [{x, y}]
        _ -> []
      end)
    end)
    |> MapSet.new()
  end

  def moveall(el, n) do
    new_el =
      for e <- el, reduce: %{} do
        proposed ->
          new_e =
            cond do
              !around?(el, e) -> e
              free?(el, n, e) -> move(n, e)
              free?(el, n + 1, e) -> move(n + 1, e)
              free?(el, n + 2, e) -> move(n + 2, e)
              free?(el, n + 3, e) -> move(n + 3, e)
              true -> e
            end

          proposed
          |> Map.put(new_e, if(proposed[new_e], do: [e | proposed[new_e]], else: [e]))
      end
      |> Enum.flat_map(fn
        {new_e, [_e]} -> [new_e]
        {_new_e, es} -> es
      end)
      |> MapSet.new()

    # |> display

    if new_el == el, do: n, else: moveall(new_el, n + 1)
  end

  def move(n, {x, y}) do
    case rem(n, 4) do
      1 -> {x, y - 1}
      2 -> {x, y + 1}
      3 -> {x - 1, y}
      0 -> {x + 1, y}
    end
  end

  def free?(el, n, {x, y}) do
    case rem(n, 4) do
      1 -> [{x, y - 1}, {x - 1, y - 1}, {x + 1, y - 1}]
      2 -> [{x, y + 1}, {x - 1, y + 1}, {x + 1, y + 1}]
      3 -> [{x - 1, y}, {x - 1, y - 1}, {x - 1, y + 1}]
      0 -> [{x + 1, y}, {x + 1, y - 1}, {x + 1, y + 1}]
    end
    |> Enum.all?(&(!MapSet.member?(el, &1)))
  end

  def around?(el, {x, y}) do
    [
      {x - 1, y - 1},
      {x, y - 1},
      {x + 1, y - 1},
      {x - 1, y},
      {x + 1, y},
      {x - 1, y + 1},
      {x, y + 1},
      {x + 1, y + 1}
    ]
    |> Enum.any?(&MapSet.member?(el, &1))
  end

  def display(el) do
    elv = el |> Enum.to_list()
    {x1, x2} = Enum.map(elv, &elem(&1, 0)) |> Enum.min_max()
    {y1, y2} = Enum.map(elv, &elem(&1, 1)) |> Enum.min_max()

    for y <- y1..y2 do
      for x <- x1..x2 do
        IO.write(if MapSet.member?(el, {x, y}), do: "#", else: ".")
      end

      IO.write("\n")
    end

    IO.write("\n")
    el
  end
end

File.read!("input.txt")
|> E.read()
# |> E.display
|> E.moveall(1)
|> IO.inspect()
