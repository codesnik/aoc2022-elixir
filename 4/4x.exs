File.stream!("input.txt")
|> Stream.map(fn line ->
  String.split(line, ["-", ",", "\n"], trim: true)
  |> Enum.map(&String.to_integer/1)
end)
|> Enum.count(fn [a,b,c,d] ->
  !Range.disjoint?(a..b, c..d)
end)
|> IO.puts
