#!/usr/bin/env elixir

File.stream!("input.txt")
|> Stream.map(&String.trim/1)
|> Enum.reduce([%{}], fn line, [monkey = %{} | monkeys] ->
  if line == "" do
    [%{}, monkey | monkeys]
  else
    updated_monkey =
      case String.split(line) do
        ["Monkey", n] ->
          Map.put(monkey, :number, String.to_integer(String.trim(n, ":")))
          |> Map.put(:business, 0)

        ["Starting", "items:" | items] ->
          Map.put(monkey, :items, Enum.map(items, &String.to_integer(String.trim(&1, ","))))

        ["Operation:", "new", "=", "old", "*", "old"] ->
          Map.put(monkey, :op, :pow)

        ["Operation:", "new", "=", "old", "*", n] ->
          Map.put(monkey, :op, {:mul, String.to_integer(n)})

        ["Operation:", "new", "=", "old", "+", n] ->
          Map.put(monkey, :op, {:add, String.to_integer(n)})

        ["Test:", "divisible", "by", n] ->
          Map.put(monkey, :test, String.to_integer(n))

        ["If", "true:", "throw", "to", "monkey", n] ->
          Map.put(monkey, true, String.to_integer(n))

        ["If", "false:", "throw", "to", "monkey", n] ->
          Map.put(monkey, false, String.to_integer(n))
      end

    [updated_monkey | monkeys]
  end
end)
|> then(fn monkey_list ->
  for monkey = %{number: n} <- monkey_list, into: %{}, do: {n, monkey}
end)
|> then(fn monkeys ->
  {monkey_min, monkey_max} = Enum.min_max(Map.keys(monkeys))

  for _ <- 1..20, current <- monkey_min..monkey_max, reduce: monkeys do
    monkeys ->
      monkey = monkeys[current]

      thrown =
        Enum.map(monkey.items, fn item ->
          trunc(
            case monkey.op do
              :pow -> item * item
              {:mul, n} -> item * n
              {:add, n} -> item + n
            end / 3
          )
        end)
        |> Enum.group_by(&(rem(&1, monkey.test) == 0))

      %{
        monkeys
        | current => %{
            monkey
            | items: [],
              business: (monkey.business || 0) + length(monkey.items)
          },
          monkey.true => %{
            monkeys[monkey.true]
            | items: monkeys[monkey.true].items ++ (thrown[true] || [])
          },
          monkey.false => %{
            monkeys[monkey.false]
            | items: monkeys[monkey.false].items ++ (thrown[false] || [])
          }
      }
  end
end)
|> Enum.map(fn {_k, v} -> v.business end)
|> Enum.sort(:desc)
|> then(fn [a, b | _] -> a * b end)
|> IO.inspect()
