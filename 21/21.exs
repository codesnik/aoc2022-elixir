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

  def call(monkeys, name) do
    case monkeys[name] do
      {name2, name3, op} -> calc(call(monkeys, name2), op, call(monkeys, name3))
      number -> number
    end
  end

  def calc(a, "+", b), do: a + b
  def calc(a, "-", b), do: a - b
  def calc(a, "*", b), do: a * b
  def calc(a, "/", b), do: div(a, b)
end

"input.txt"
|> File.stream!()
|> Enum.map(&String.trim/1)
|> Enum.map(&X.read/1)
|> Map.new()
|> X.call("root")
|> IO.inspect()
