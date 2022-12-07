IO.puts(
  File.stream!("input.txt")
  |> Stream.map(&String.trim/1)
  |> Stream.map(fn line ->
    {l, r} = String.split_at(line, div(String.length(line), 2))
    code = MapSet.intersection(MapSet.new(String.codepoints(l)), MapSet.new(String.codepoints(r)))
    |> Enum.at(0)
    |> String.to_charlist
    |> hd

    cond do
      code in ?a..?z -> code - 96
      code in ?A..?Z -> code - 38
    end
  end)
  |> Enum.sum
)
