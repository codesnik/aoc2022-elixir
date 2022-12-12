#!/usr/bin/env elixir

File.stream!("input.txt")
|> Stream.map(&String.split/1)
|> Stream.flat_map(fn
  ["noop"] -> [0]
  ["addx", amount] -> [0, String.to_integer(amount)]
end)
|> Stream.scan(1, &(&1 + &2))
|> Stream.with_index(2) # signal on the start of the cycle
|> then(fn stream ->
  for {x, step} <- stream, step in 20..220//40, do: x * step
end)
|> Enum.sum
|> IO.puts
