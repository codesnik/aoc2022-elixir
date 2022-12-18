#!/usr/bin/env elixir

defmodule V do
  def walk(paths, rates, moves) do
    unopened = for {valve, rate} <- rates, rate > 0, do: valve
    walk(paths, rates, moves, "AA", unopened, 0, 0)
  end

  def walk(paths, rates, moves, current, unopened, rate, released) do
    Enum.max([
      released + rate * moves
      | for(
          exit <- unopened,
          paths[current][exit],
          distance = paths[current][exit] + 1,
          distance < moves,
          do:
            walk(
              paths,
              rates,
              moves - distance,
              exit,
              unopened -- [exit],
              rate + rates[exit],
              released + distance * rate
            )
        )
    ])
  end

  def grow_paths(paths) do
    new_paths =
      for {valve, costs} <- paths, into: %{} do
        {valve,
         for {next, nextcost} <- costs, reduce: costs do
           costs ->
             Map.merge(
               for(
                 {othernext, othercost} <- paths[next],
                 into: %{},
                 do: {othernext, nextcost + othercost}
               ),
               costs,
               fn _, a, b -> min(a, b) end
             )
         end}
      end

    if new_paths != paths do
      grow_paths(new_paths)
    else
      paths
    end
  end
end

if System.argv() == [] do
  File.stream!("input.txt")
  |> Stream.map(fn line ->
    [valve, rate, tunnels] =
      Regex.run(~r/Valve (..) has flow rate=(\d+); tunnels? leads? to valves? (.*)/, line,
        capture: :all_but_first
      )

    {valve, String.to_integer(rate), String.split(tunnels, ", ")}
  end)
  |> then(fn valves ->
    rates = for {valve, rate, _exits} <- valves, into: %{}, do: {valve, rate}

    paths =
      for {valve, _rate, exits} <- valves,
          into: %{},
          do: {valve, for(exit <- exits, into: %{}, do: {exit, 1})}

    paths = V.grow_paths(paths)

    V.walk(paths, rates, 30)
  end)
  |> IO.inspect()
else
  ExUnit.start()

  defmodule VTest do
    use ExUnit.Case

    test "sample" do
      assert V.walk(%{"AA" => %{"BB" => 1}, "BB" => %{}}, %{"BB" => 3}, 3) == 3
    end

    test "sample 2" do
      assert V.walk(%{"AA" => %{"BB" => 1}, "BB" => %{"CC" => 2}}, %{"BB" => 3, "CC" => 1}, 5) ==
               9

      assert V.walk(%{"AA" => %{"BB" => 1}, "BB" => %{"CC" => 2}}, %{"BB" => 3, "CC" => 1}, 7) ==
               17
    end
  end
end
