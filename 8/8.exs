#!/usr/bin/env elixir
count_reverse = fn row, prev_count ->
  Enum.reduce(row, {0, prev_count, []}, fn
    {height, false}, {prev_height, count, rest} when height > prev_height ->
      {height, count + 1, [{height, true} | rest]}

    {height, visited}, {prev_height, count, rest} ->
      {max(height, prev_height), count, [{height, visited} | rest]}
  end)
  |> case do
    {_, count, reversed_row} -> {reversed_row, count}
  end
end

File.stream!("input.txt")
|> Stream.map(&String.trim/1)
|> Enum.map(fn line -> Enum.map(String.to_charlist(line), &{&1, false}) end)
|> case do
  rows -> {rows, 0}
end
|> case do
  {rows, count} -> Enum.map_reduce(rows, count, count_reverse)
end
|> case do
  {rows, count} -> Enum.map_reduce(rows, count, count_reverse)
end
|> case do
  {rows, count} -> {Enum.zip_with(rows, & &1), count}
end
|> case do
  {rows, count} -> Enum.map_reduce(rows, count, count_reverse)
end
|> case do
  {rows, count} -> Enum.map_reduce(rows, count, count_reverse)
end
|> case do
  {_rows, count} -> count
end
|> IO.puts()
