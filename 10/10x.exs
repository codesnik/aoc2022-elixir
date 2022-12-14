#!/usr/bin/env elixir

File.stream!("input.txt")
|> Stream.map(&String.split/1)
|> Stream.flat_map(fn
  ["noop"] -> [0]
  ["addx", amount] -> [0, String.to_integer(amount)]
end)
|> Stream.scan(1, &(&1 + &2))
|> then(fn stream -> Stream.concat([1], stream) end)
# signal on the start of the cycle
|> Stream.with_index(1)
|> Enum.each(fn {x, idx} ->
  if abs(rem(idx - 1, 40) - x) <= 1 do
    IO.write("*")
  else
    IO.write(" ")
  end

  if rem(idx - 1, 40) == 39 do
    IO.write("\n")
  end
end)
