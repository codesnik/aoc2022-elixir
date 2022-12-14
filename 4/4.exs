File.stream!("input.txt")
|> Stream.map(fn line ->
  String.split(line, ["-", ",", "\n"], trim: true)
  |> Enum.map(&String.to_integer/1)
end)
|> Enum.count(fn [a, b, c, d] ->
  (a <= c && b >= d) || (a >= c && b <= d)
end)
|> IO.puts()
