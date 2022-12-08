File.read!("input.txt")
|> String.codepoints()
|> Stream.chunk_every(14, 1, :discard)
|> Stream.map(&Enum.uniq/1)
|> Stream.map(&length/1)
|> Stream.with_index(14)
|> Enum.find(&(elem(&1, 0) == 14))
|> elem(1)
|> IO.puts
