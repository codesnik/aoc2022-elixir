max = File.stream!("input.txt")
|> Stream.map(&String.trim/1)
|> Stream.chunk_by(fn l -> l != "" end)
|> Stream.filter(fn c -> c != [""] end)
|> Stream.map(
  fn chunk ->
    chunk
    |> Stream.map( &String.to_integer/1 )
    |> Enum.sum
  end
)
|> Enum.sort(:desc)
|> Enum.take(3)
|> Enum.sum

IO.puts max
