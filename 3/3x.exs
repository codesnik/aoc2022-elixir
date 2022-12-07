IO.puts(
  File.stream!("input.txt")
  |> Stream.map(fn line ->
    line
    |> String.trim
    |> String.codepoints
    |> MapSet.new
  end)
  |> Stream.chunk_every(3)
  |> Stream.map(fn chunk ->
    code = Enum.reduce(chunk, &MapSet.intersection/2)
    |> Enum.at(0)
    |> String.first
    |> String.to_charlist
    |> hd
    cond do
      code in ?a..?z -> code - 96
      code in ?A..?Z -> code - 38
    end
  end)
  |> Enum.sum
)
