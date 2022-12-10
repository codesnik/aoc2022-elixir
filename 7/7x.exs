# wildly assumes no directory is ever ls-ed twice

sum_back = fn
  [] -> []
  [top | others] -> Enum.reduce(others, [top], fn dir, acc = [prev | _] -> [ dir+prev | acc] end)
end

File.stream!("input.txt")
|> Stream.map(&String.split/1)
|> Enum.reduce(%{dirs: [], current: 0, visited: []}, fn line, state ->
  case line do
    ["$", "cd", "/"] -> state # noop, happens only at the start
    ["$", "cd", ".."] -> %{state | dirs: tl(state.dirs), current: state.current + hd(state.dirs),
        visited: [state.current | state.visited]}
    ["$", "cd", _dir] -> %{state | dirs: [state.current | state.dirs], current: 0}
    ["$", "ls"] -> state
    ["dir", _dir] -> state # who cares, hopefully we visit it later
    [size, _file] -> %{state | current: state.current + String.to_integer(size) }
  end
end)
|> then(fn state ->
  visited = state.visited ++ sum_back.([state.current | state.dirs])
  visited = Enum.sort(visited, :desc)
  free = 70_000_000 - hd(visited)
  to_free = 30_000_000 - free
  Enum.find(Enum.reverse(visited), &(&1 > to_free))
end)
|> IO.puts
