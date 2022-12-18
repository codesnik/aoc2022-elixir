#!/usr/bin/env elixir

defmodule Tetris do
  import Bitwise

  @left_border  0b100_0000
  @right_border 0b000_0001
  @full_row     0b111_1111
  @figures [
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
      0b0011000,
    ]
  ]
  @figures_size 5

  def prepend_space(highest, board) do
    {highest + 7, [0, 0, 0, 0, 0, 0, 0 | board]}
  end

  def drop_empty(highest, [0 | board]), do: drop_empty(highest - 1, board)
  def drop_empty(highest, board), do: {highest, board}

  def fix_figure([f1,f2,f3,f4], [b1,b2,b3,b4|rest]) do
    applied = [f1|||b1, f2|||b2, f3|||b3, f4|||b4]
    if Enum.any?(applied, &(&1 == @full_row)) do
      applied
    else
      applied ++ rest
    end
  end

  # TODO: implement board cut-off
  def update_board(board, highest, figure, drops) do
    {prefix, rest} = Enum.split(board, drops)
    drop_empty(highest, prefix ++ fix_figure(figure, rest))
  end

  def move_left(figure, board) do
    new_figure =
      if Enum.all?(figure, &((@left_border &&& &1)==0)) do
        Enum.map(figure, &bsl(&1, 1))
      else
        figure
      end
    if free?(new_figure, board) do
      new_figure
    else
      figure
    end
  end

  def move_right(figure, board) do
    new_figure =
      if Enum.all?(figure, &((@right_border &&& &1)==0)) do
        Enum.map(figure, &bsr(&1, 1))
      else
        figure
      end
    if free?(new_figure, board) do
      new_figure
    else
      figure
    end
  end

  def move_down?(figure, [_skip | board]), do: free?(figure, board)

  def free?([f1, f2, f3, f4], [b1, b2, b3, b4 | _]) do
    (f1 &&& b1 ||| f2 &&& b2 ||| f3 &&& b3 ||| f4 &&& b4) == 0
  end
  def free?(_, _), do: false

  def display_board([row | rest]) do
    IO.puts(for n <- 6..0, do: if (row >>> n &&& 1) == 0, do: ?., else: ?#)
    display_board(rest)
  end
  def display_board([]), do: IO.puts("")

  # not needed anymore
  def recurse(acc, func) do
    case func.(acc) do
      {:cont, new_acc} -> recurse(new_acc, func)
      {:halt, new_acc} -> new_acc
    end
  end

  def drop_and_update(board, highest_point, moves_offset, figure_n, moves_binary) do
    figure = Enum.at(@figures, rem(figure_n-1, @figures_size))
    {highest_point, board} = Tetris.prepend_space(highest_point, board)
    {shifted_figure, drops} = drop(board, figure, moves_binary, moves_offset, 0)
    {new_highest_point, updated_board} = Tetris.update_board(board, highest_point, shifted_figure, drops)
    {updated_board, new_highest_point, moves_offset + drops + 1}
  end

  def drop(board_window, figure, moves_binary, moves_offset, drops) do
    move = :binary.at(moves_binary, rem(moves_offset + drops, :erlang.size(moves_binary)))
    figure =
      case move do
        ?< -> Tetris.move_left(figure, board_window)
        ?> -> Tetris.move_right(figure, board_window)
      end

    if Tetris.move_down?(figure, board_window) do
      drop(Enum.drop(board_window, 1), figure, moves_binary, moves_offset, drops + 1)
    else
      {figure, drops}
    end
  end
end

moves_binary = File.read!("input.txt") |> String.trim()

total = 1_000_000_000_000
{_board, new_highest_point, _used_moves} =
  for figure_n <- 1..total, reduce: {_board = [], 0, 0} do
    {board, highest_point, moves_offset} ->
      #if rem(n,10000) == 0, do: IO.puts(highest_point)
      # Tetris.display_board(board)
      Tetris.drop_and_update(board, highest_point, moves_offset, figure_n, moves_binary)
  end

#Tetris.display_board(board)
IO.puts(new_highest_point)
