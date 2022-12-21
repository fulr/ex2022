defmodule Day21 do
  def parse do
    File.read!("input/input21.txt")
    |> String.replace("\r\n", "\n")
    |> String.split("\n")
    |> Enum.map(fn l ->
      [monkey, rest] = String.split(l, ": ")

      case Integer.parse(rest) do
        {i, ""} ->
          {monkey, i}

        _ ->
          [a, op, b] = String.split(rest, " ")
          {monkey, {a, op, b}}
      end
    end)
    |> Map.new()
  end

  @doc """
  Part1

  ## Examples

    iex> Day21.part1()
    232974643455000

  """
  def part1 do
    parse()
    |> build_ast("root")
    |> calc()
  end

  def build_ast(ops, {a, op, b}), do: {build_ast(ops, a), op, build_ast(ops, b)}
  def build_ast(_ops, a) when is_integer(a) or is_atom(a), do: a
  def build_ast(ops, a), do: build_ast(ops, ops[a])

  def calc(x) when is_integer(x), do: x
  def calc({a, "+", b}), do: calc(a) + calc(b)
  def calc({a, "-", b}), do: calc(a) - calc(b)
  def calc({a, "*", b}), do: calc(a) * calc(b)
  def calc({a, "/", b}), do: div(calc(a), calc(b))

  @doc """
  Part2

  ## Examples

    iex> Day21.part2()
    3740214169961

  """
  def part2 do
    parse()
    |> put_in(["humn"], :var)
    |> update_in(["root"], fn {a, _, b} -> {a, "=", b} end)
    |> build_ast("root")
    |> solve()
  end

  def solve({a, "=", b}) do
    if contains_var(a) do
      solve(a, calc(b))
    else
      solve(b, calc(a))
    end
  end

  def solve(a, b) when is_atom(a), do: b

  def solve({a, "+", b}, c) do
    if contains_var(a) do
      solve(a, c - calc(b))
    else
      solve(b, c - calc(a))
    end
  end

  def solve({a, "-", b}, c) do
    if contains_var(a) do
      solve(a, c + calc(b))
    else
      solve(b, calc(a) - c)
    end
  end

  def solve({a, "*", b}, c) do
    if contains_var(a) do
      solve(a, div(c, calc(b)))
    else
      solve(b, div(c, calc(a)))
    end
  end

  def solve({a, "/", b}, c) do
    if contains_var(a) do
      solve(a, c * calc(b))
    else
      solve(b, div(calc(a), c))
    end
  end

  def contains_var(a) when is_atom(a), do: true
  def contains_var(a) when is_integer(a), do: false
  def contains_var({a, _, b}), do: contains_var(a) || contains_var(b)
end
