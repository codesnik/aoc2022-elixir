#!/usr/bin/env elixir

# actually can handle any cube maps!
defmodule X do
  @north 3
  @east 0
  @south 1
  @west 2

  def read_map(string) do
    string
    |> String.trim_trailing()
    |> String.split("\n")
    |> Enum.map(&String.to_charlist/1)
  end

  def parse_moves(moves_string) do
    String.trim(moves_string)
    |> then(&Regex.scan(~r/\d+|./, &1))
    |> Enum.map(fn
      ["L"] -> :left
      ["R"] -> :right
      [n] -> String.to_integer(n)
    end)
  end

  def make_warps(map) do
    max_y = length(map)
    max_x = map |> Enum.map(&length/1) |> Enum.max()

    {max_cx, max_cy, cell} = geometry(max_x, max_y)

    cells =
      for y <- 0..(max_cy - 1),
          x <- 0..(max_cx - 1),
          map_at({x * cell + 1, y * cell + 1}, map) != ?\s,
          do: {x, y}

    conns = conns(cells)

    Map.new(
      for {{cx, cy, dir}, {ncx, ncy, rot}} <- conns,
          exit_dir = norm(dir + rot),
          {enter_xy, exit_xy} <-
            Enum.zip(
              warp_enters(cell, dir, cx, cy),
              warp_exits(cell, exit_dir, ncx, ncy)
            ),
          do: {{dir, enter_xy}, {exit_dir, exit_xy}}
    )
  end

  # cube map could be only 3x4 or 2x5
  def geometry(max_x, max_y) do
    cond do
      max_x * 3 == max_y * 4 -> {4, 3, div(max_x, 4)}
      max_x * 4 == max_y * 3 -> {3, 4, div(max_x, 3)}
      max_x * 5 == max_y * 2 -> {2, 5, div(max_x, 2)}
      max_x * 2 == max_y * 5 -> {5, 2, div(max_x, 5)}
    end
  end

  def map_at({x, y}, map) do
    map |> Enum.at(y - 1) |> Enum.at(x - 1, ?\s)
  end

  def first_coords(map) do
    x = 1 + (map |> Enum.at(0) |> Enum.take_while(fn x -> x == ?\s end) |> length)
    {x, 1}
  end

  def norm(facing), do: rem(facing + 4, 4)

  def start_walk(map, warps, moves) do
    facing = @east
    start_coords = first_coords(map)
    walk(map, warps, start_coords, facing, moves, Map.new())
  end

  def walk(_map, _warps, {x, y}, facing, [], _hist) do
    # display(map, hist)
    {facing, x, y}
  end

  def walk(map, warps, coords, facing, [move | moves], hist) do
    case move do
      :left ->
        walk(map, warps, coords, norm(facing - 1), moves, hist)

      :right ->
        walk(map, warps, coords, norm(facing + 1), moves, hist)

      0 ->
        walk(map, warps, coords, facing, moves, hist)

      n ->
        {nfacing, ncoords} = forward(map, warps, coords, facing)
        hist = Map.put(hist, ncoords, nfacing)
        walk(map, warps, ncoords, nfacing, [n - 1 | moves], hist)
    end
  end

  def shift(@east, {x, y}), do: {x + 1, y}
  def shift(@south, {x, y}), do: {x, y + 1}
  def shift(@west, {x, y}), do: {x - 1, y}
  def shift(@north, {x, y}), do: {x, y - 1}

  def forward(map, warps, coords, facing) do
    {nfacing, ncoords} = Map.get(warps, {facing, coords}, {facing, shift(facing, coords)})
    if map_at(ncoords, map) == ?#, do: {facing, coords}, else: {nfacing, ncoords}
  end

  def conns(cells) do
    # directly connected cells, no rotation
    links =
      for {x, y} <- cells,
          {dir, nx, ny} <- [
            {@east, x + 1, y},
            {@south, x, y + 1},
            {@west, x - 1, y},
            {@north, x, y - 1}
          ],
          {nx, ny} in cells,
          into: %{},
          do: {{x, y, dir}, {nx, ny, 0}}

    # fold cutout three times, calculating rotation on touching sides
    for _ <- 1..3, reduce: links do
      links ->
        for(
          {{x, y, dir}, {nx, ny, rot}} <- links,
          turn <- [-1, 1],
          !links[{x, y, norm(dir + turn)}],
          {rx, ry, rrot} <- [links[{nx, ny, norm(dir + rot + turn)}]],
          do: {{x, y, norm(dir + turn)}, {rx, ry, norm(rot + rrot - turn)}}
        )
        |> Enum.into(links)
    end
  end

  # gives all the coords on the exiting border of a cell for a dir
  def warp_enters(cell, dir, cx, cy) do
    case dir do
      @east -> for y <- 1..cell, do: {cell + cell * cx, y + cell * cy}
      @south -> for x <- cell..1, do: {x + cell * cx, cell + cell * cy}
      @west -> for y <- cell..1, do: {1 + cell * cx, y + cell * cy}
      @north -> for x <- 1..cell, do: {x + cell * cx, 1 + cell * cy}
    end
  end

  def warp_exits(cell, dir, cx, cy) do
    Enum.reverse(warp_enters(cell, norm(dir + 2), cx, cy))
  end

  def display(map, hist) do
    max_y = length(map)
    max_x = map |> Enum.map(&length/1) |> Enum.max()

    for y <- 1..max_y do
      IO.puts(
        for x <- 1..max_x do
          case hist[{x, y}] do
            @west -> ?<
            @south -> ?v
            @east -> ?>
            @north -> ?^
            _ -> map_at({x, y}, map)
          end
        end
      )
    end

    IO.puts("")
  end
end

if System.argv() != ["test"] do
  [mapstr, movesstr] =
    "input.txt"
    |> File.read!()
    |> String.split("\n\n")

  moves = X.parse_moves(movesstr)
  map = X.read_map(mapstr)
  warps = X.make_warps(map)
  {facing, x, y} = X.start_walk(map, warps, moves)
  IO.puts(1000 * y + 4 * x + facing)
else
  ExUnit.start()

  defmodule XTest do
    use ExUnit.Case

    test "conns" do
      dots = [{1, 0}, {1, 1}, {1, 2}, {1, 3}, {0, 1}, {2, 1}]
      conns = X.conns(dots)

      result = %{
        {0, 1, 0} => {1, 1, 0},
        {0, 1, 1} => {1, 2, 3},
        {0, 1, 2} => {1, 3, 2},
        {0, 1, 3} => {1, 0, 1},
        {1, 0, 0} => {2, 1, 1},
        {1, 0, 1} => {1, 1, 0},
        {1, 0, 2} => {0, 1, 3},
        {1, 0, 3} => {1, 3, 0},
        {1, 1, 0} => {2, 1, 0},
        {1, 1, 1} => {1, 2, 0},
        {1, 1, 2} => {0, 1, 0},
        {1, 1, 3} => {1, 0, 0},
        {1, 2, 0} => {2, 1, 3},
        {1, 2, 1} => {1, 3, 0},
        {1, 2, 2} => {0, 1, 1},
        {1, 2, 3} => {1, 1, 0},
        {1, 3, 0} => {2, 1, 2},
        {1, 3, 1} => {1, 0, 0},
        {1, 3, 2} => {0, 1, 2},
        {1, 3, 3} => {1, 2, 0},
        {2, 1, 0} => {1, 3, 2},
        {2, 1, 1} => {1, 2, 1},
        {2, 1, 2} => {1, 1, 0},
        {2, 1, 3} => {1, 0, 3}
      }

      assert conns == result
    end
  end
end
