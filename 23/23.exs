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

  def moveall(el, rounds) do
    for n <- 0..(rounds - 1), reduce: el do
      el ->
        for e <- el, reduce: %{} do
          proposed ->
            new_e =
              cond do
                !Enum.any?(surrounding(e), &MapSet.member?(el, &1)) -> e
                !Enum.any?(checks(n, e), &MapSet.member?(el, &1)) -> move(n, e)
                !Enum.any?(checks(n + 1, e), &MapSet.member?(el, &1)) -> move(n + 1, e)
                !Enum.any?(checks(n + 2, e), &MapSet.member?(el, &1)) -> move(n + 2, e)
                !Enum.any?(checks(n + 3, e), &MapSet.member?(el, &1)) -> move(n + 3, e)
                true -> e
              end

            if proposed[new_e] do
              Map.put(proposed, new_e, [e | proposed[new_e]])
            else
              Map.put(proposed, new_e, [e])
            end
        end
        |> Enum.flat_map(fn
          {new_e, [_e]} -> [new_e]
          {_new_e, es} -> es
        end)
        |> MapSet.new()

        # |> display
    end
  end

  def move(n, {x, y}) do
    case rem(n, 4) do
      0 -> {x, y - 1}
      1 -> {x, y + 1}
      2 -> {x - 1, y}
      3 -> {x + 1, y}
    end
  end

  def checks(n, {x, y}) do
    case rem(n, 4) do
      0 -> [{x, y - 1}, {x - 1, y - 1}, {x + 1, y - 1}]
      1 -> [{x, y + 1}, {x - 1, y + 1}, {x + 1, y + 1}]
      2 -> [{x - 1, y}, {x - 1, y - 1}, {x - 1, y + 1}]
      3 -> [{x + 1, y}, {x + 1, y - 1}, {x + 1, y + 1}]
    end
  end

  def surrounding({x, y}) do
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
  end

  def answer(elv) do
    elv = elv |> Enum.to_list()
    l = length(elv)
    {x1, x2} = Enum.map(elv, &elem(&1, 0)) |> Enum.min_max()
    {y1, y2} = Enum.map(elv, &elem(&1, 1)) |> Enum.min_max()
    (x2 - x1 + 1) * (y2 - y1 + 1) - l
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
|> E.display()
|> E.moveall(10)
|> E.answer()
|> IO.inspect()
