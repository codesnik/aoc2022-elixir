#!/usr/bin/env elixir

defmodule Tetris do
  @left_border 0
  @right_border 6
  @bottom_border 1

  def figure_drop(figure, height) do
    for {x, y} <- figure, do: {x + 2, y + height + 4}
  end

  def move_left(figure, board) do
    moved_figure = Enum.map(figure, fn {x, y} -> {x - 1, y} end)

    if Enum.all?(moved_figure, fn coords = {x, _y} ->
         x >= @left_border && !MapSet.member?(board, coords)
       end) do
      moved_figure
    else
      figure
    end
  end

  def move_right(figure, board) do
    moved_figure = Enum.map(figure, fn {x, y} -> {x + 1, y} end)

    if Enum.all?(moved_figure, fn coords = {x, _y} ->
         x <= @right_border && !MapSet.member?(board, coords)
       end) do
      moved_figure
    else
      figure
    end
  end

  def move_down(figure, board) do
    moved_figure = Enum.map(figure, fn {x, y} -> {x, y - 1} end)

    if Enum.all?(moved_figure, fn coords = {_x, y} ->
         y >= @bottom_border && !MapSet.member?(board, coords)
       end) do
      moved_figure
    else
      :cant_move
    end
  end

  def update_board(figure, board, highest_point) do
    new_board = Enum.reduce(figure, board, fn dot, board -> MapSet.put(board, dot) end)
    new_highest_point = max(highest_point, Enum.max(for {_x, y} <- figure, do: y))
    {new_board, new_highest_point}
  end

  def display_board(board, figure) do
    max_y = Stream.concat(figure, board) |> Stream.map(&elem(&1, 1)) |> Enum.max
    figureset = MapSet.new(figure)
    for y <- max_y..0 do
      IO.write Integer.to_string(y) |> String.pad_leading(3) |> String.pad_trailing(4)
      IO.write(for x <- @left_border..@right_border do
        cond do
          MapSet.member?(board, {x, y}) -> ?#
          MapSet.member?(figureset, {x, y}) -> ?@
          true -> ?.
        end
      end)
      IO.puts("")
    end
    IO.puts("")
  end
end

moves_chars = File.read!("input.txt") |> String.trim() |> String.to_charlist()

moves_size = length(moves_chars)

moves_stream = moves_chars |> Stream.cycle()

figures =
  [
    [{0, 0}, {1, 0}, {2, 0}, {3, 0}],
    [{1, 0}, {0, 1}, {1, 1}, {2, 1}, {1, 2}],
    [{0, 0}, {1, 0}, {2, 0}, {2, 1}, {2, 2}],
    [{0, 0}, {0, 1}, {0, 2}, {0, 3}],
    [{0, 0}, {0, 1}, {1, 0}, {1, 1}]
  ]
  |> Stream.cycle()

{_board, new_highest_point, _used_moves} =
  for {_, figure} <- Stream.zip(1..2022, figures), reduce: {MapSet.new(), 0, 0} do
    # drop a figure
    {board, highest_point, moves_offset} ->
      moves_stream = Stream.drop(moves_stream, rem(moves_offset, moves_size))
      # TODO: check if that should be 4
      figure = Tetris.figure_drop(figure, highest_point)
      # Tetris.display_board(board, figure)

      Enum.reduce_while(moves_stream, {figure, moves_offset}, fn move, {figure, moves_offset} ->
        figure =
          case move do
            ?< -> Tetris.move_left(figure, board)
            ?> -> Tetris.move_right(figure, board)
          end

        case Tetris.move_down(figure, board) do
          :cant_move ->
            # Tetris.display_board(board, figure)
            {updated_board, new_highest_point} = Tetris.update_board(figure, board, highest_point)
            {:halt, {updated_board, new_highest_point, moves_offset + 1}}

          new_figure ->
            # Tetris.display_board(board, new_figure)
            {:cont, {new_figure, moves_offset + 1}}
        end
      end)
  end

# Tetris.display_board(board, [])
IO.puts(new_highest_point)
