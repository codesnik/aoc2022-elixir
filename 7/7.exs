# wildly assumes no directory is ever ls-ed twice
selector = fn num -> if num <= 100_000, do: num, else: 0 end

sum_back = fn
  [] -> []
  [top | others] -> Enum.reduce(others, [top], fn dir, acc = [prev | _] -> [dir + prev | acc] end)
end

File.stream!("input.txt")
|> Stream.map(&String.split/1)
|> Enum.reduce(%{dirs: [], current: 0, sum: 0}, fn line, state ->
  case line do
    # noop, happens only at the start
    ["$", "cd", "/"] ->
      state

    ["$", "cd", ".."] ->
      %{
        state
        | dirs: tl(state.dirs),
          current: state.current + hd(state.dirs),
          sum: state.sum + selector.(state.current)
      }

    ["$", "cd", _dir] ->
      %{state | dirs: [state.current | state.dirs], current: 0}

    ["$", "ls"] ->
      state

    # who cares, hopefully we visit it later
    ["dir", _dir] ->
      state

    [size, _file] ->
      %{state | current: state.current + String.to_integer(size)}
  end
end)
|> then(fn state ->
  state.sum + (sum_back.([state.current | state.dirs]) |> Enum.map(selector) |> Enum.sum())
end)
|> IO.puts()
