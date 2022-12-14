defmodule AOC2x do
  def run do
    File.stream!("input.txt")
    |> Stream.map(&String.split/1)
    |> Stream.map(fn [his, mine] -> shape_score(his, mine) + game_score(mine) end)
    |> Enum.sum()
    |> IO.puts()
  end

  def game_score("X"), do: 0
  def game_score("Y"), do: 3
  def game_score("Z"), do: 6

  def succ("A"), do: "B"
  def succ("B"), do: "C"
  def succ("C"), do: "A"

  def prev("A"), do: "C"
  def prev("B"), do: "A"
  def prev("C"), do: "B"

  def shape_score(piece, move) do
    your_shape =
      case move do
        "X" -> prev(piece)
        "Y" -> piece
        "Z" -> succ(piece)
      end

    case your_shape do
      "A" -> 1
      "B" -> 2
      "C" -> 3
    end
  end
end

AOC2x.run()
