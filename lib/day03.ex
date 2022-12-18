defmodule Day03 do
  def parse do
    File.read!("input/input03.txt")
    |> String.replace("\r\n", "\n")
    |> String.split("\n")
  end

  @doc """
  Part1

  ## Examples

    iex> Day03.part1()
    7967

  """
  def part1 do
    parse()
    |> Enum.map(&Day03.split_diff/1)
    |> Enum.map(&Day03.prio/1)
    |> Enum.sum()
  end

  def split_diff(s) do
    l = String.length(s)
    {a, b} = String.split_at(s, div(l, 2))
    as = MapSet.new(String.to_charlist(a))
    bs = MapSet.new(String.to_charlist(b))

    MapSet.intersection(as, bs)
    |> MapSet.to_list()
    |> hd()
  end

  def prio(c) when c >= ?a and c <= ?z do
    c - ?a + 1
  end

  def prio(c) when c >= ?A and c <= ?Z do
    c - ?A + 27
  end

  @doc """
  Part2

  ## Examples

    iex> Day03.part2()
    2716

  """
  def part2 do
    parse()
    |> Enum.chunk_every(3)
    |> Enum.map(&Day03.diff/1)
    |> Enum.map(&Day03.prio/1)
    |> Enum.sum()
  end

  def diff([a, b, c]) do
    as = MapSet.new(String.to_charlist(a))
    bs = MapSet.new(String.to_charlist(b))
    cs = MapSet.new(String.to_charlist(c))

    MapSet.intersection(as, bs)
    |> MapSet.intersection(cs)
    |> MapSet.to_list()
    |> hd()
  end
end
