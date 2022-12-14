parse_crates = fn crates ->
  [num_lines | crate_lines] =
    crates
    |> String.split("\n")
    |> Enum.reverse()

  count = String.to_integer(List.last(String.split(num_lines)))

  crates =
    for n <- 1..count do
      {n,
       Enum.reverse(
         for line <- crate_lines,
             char = String.at(line, (n - 1) * 4 + 1),
             char != " ",
             do: char
       )}
    end

  {count, Map.new(crates)}
end

parse_moves = fn moves ->
  moves =
    moves
    |> String.split("\n", trim: true)
    |> Enum.map(fn move ->
      Regex.run(~r/move (\d+) from (\d+) to (\d+)/, move)
      |> Enum.drop(1)
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)

  for {count, from, to} <- moves, _ <- 1..count do
    {from, to}
  end
end

make_move = fn crates, {from, to} ->
  [box | new_from] = crates[from]
  new_to = [box | crates[to]]
  %{crates | from => new_from, to => new_to}
end

[crates, moves] = File.read!("input.txt") |> String.split("\n\n")

{count, crates} = parse_crates.(crates)

moves = parse_moves.(moves)

new_crates =
  Enum.reduce(moves, crates, fn move, crates ->
    make_move.(crates, move)
  end)

IO.puts(Enum.join(for n <- 1..count, do: hd(new_crates[n])))
