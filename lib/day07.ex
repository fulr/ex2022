defmodule Day07 do
  def parse do
    File.read!("input/input07.txt")
    |> String.replace("\r\n", "\n")
    |> String.split("\n")
  end

  def interpret("$ cd /", _) do
    %{cwd: [], dirs: %{}}
  end

  def interpret("$ cd ..", acc) do
    %{acc | cwd: tl(acc.cwd)}
  end

  def interpret("$ cd " <> dir, acc) do
    %{acc | cwd: [dir | acc.cwd]}
  end

  def interpret("$ ls", acc) do
    acc
  end

  def interpret("dir " <> _, acc) do
    acc
  end

  def interpret(s, acc) do
    [a, _f] = String.split(s, " ")
    n = update_dirs(acc.dirs, acc.cwd, String.to_integer(a))
    %{acc | dirs: n}
  end

  def update_dirs(dirs, cwd, size) do
    Enum.reverse(cwd)
    |> Enum.reduce({[], dirs}, fn p, {c, d} ->
      {[p | c], Map.update(d, c, size, &(&1 + size))}
    end)
    |> elem(1)
    |> Map.update(cwd, size, &(&1 + size))
  end

  @doc """
  Part1

  ## Examples

    iex> Day07.part1()
    nil

  """
  def part1 do
    Day07.parse()
    |> Enum.reduce(%{}, &Day07.interpret/2)
    |> Map.get(:dirs)
    |> Map.filter(fn {_k, v} -> v < 100_000 end)
    |> Map.values()
    |> Enum.sum()
  end

  @doc """
  Part2

  ## Examples

    iex> Day07.part2()
    nil

  """
  def part2 do
    dirs=Day07.parse()
    |> Enum.reduce(%{}, &Day07.interpret/2)
    |> Map.get(:dirs)

    root=
  end
end
