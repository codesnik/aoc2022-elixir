#!/usr/bin/env elixir

defmodule X do
  def read(line) do
    case line do
      <<name::binary-4, ": ", name2::binary-4, " ", op::binary-1, " ", name3::binary-4>> ->
        {name, {name2, name3, op}}

      <<name::binary-4, ": ", number::binary>> ->
        {name, String.to_integer(number)}
    end
  end

  def answer(monkeys) do
    {name2, name3, _} = monkeys["root"]

    case {call(monkeys, name2), call(monkeys, name3)} do
      {{:humn, ops}, b} -> recalc(b, ops)
      {a, {:humn, ops}} -> recalc(a, ops)
    end
  end

  def call(_monkeys, "humn"), do: {:humn, []}

  def call(monkeys, name) do
    case monkeys[name] do
      {name2, name3, op} -> calc(call(monkeys, name2), op, call(monkeys, name3))
      number -> number
    end
  end

  def calc(a, op, {:humn, ops}), do: {:humn, [{a, op} | ops]}
  def calc({:humn, ops}, op, b), do: {:humn, [{op, b} | ops]}

  def calc(a, "+", b), do: a + b
  def calc(a, "-", b), do: a - b
  def calc(a, "*", b), do: a * b
  def calc(a, "/", b), do: div(a, b)

  def recalc(x, []), do: x

  def recalc(x, [pair | rest]) do
    case pair do
      {"+", a} -> recalc(x - a, rest)
      {a, "+"} -> recalc(x - a, rest)
      {"-", a} -> recalc(a + x, rest)
      {a, "-"} -> recalc(a - x, rest)
      {"*", a} -> recalc(div(x, a), rest)
      {a, "*"} -> recalc(div(x, a), rest)
      {"/", a} -> recalc(x * a, rest)
      {a, "/"} -> recalc(div(a, x), rest)
    end
  end
end

"input.txt"
|> File.stream!()
|> Enum.map(&String.trim/1)
|> Enum.map(&X.read/1)
|> Map.new()
|> X.answer()
|> IO.inspect()
