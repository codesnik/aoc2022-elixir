defmodule AOC2 do
  def run do
    File.stream!("input.txt")
    |> Stream.map(&String.split/1)
    |> Stream.map(fn [his, mine] -> shape_score(mine) + game_score(his, mine) end)
    |> Enum.sum
    |> IO.puts
  end

  def shape_score("X"), do: 1
  def shape_score("Y"), do: 2
  def shape_score("Z"), do: 3

  def game_score(a, b) do
    case a do
      "A" -> case b do
        "X" -> 3
        "Y" -> 6
        "Z" -> 0
      end
      "B" -> case b do
        "X" -> 0
        "Y" -> 3
        "Z" -> 6
      end
      "C" -> case b do
        "X" -> 6
        "Y" -> 0
        "Z" -> 3
      end
    end
  end
end

AOC2.run
