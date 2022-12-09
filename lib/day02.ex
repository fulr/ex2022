defmodule Day02 do
  def parse do
    File.read!("input/input02.txt")
    |> String.split("\n")
  end

  def calc("A X"), do: 1 + 3
  def calc("A Y"), do: 2 + 6
  def calc("A Z"), do: 3 + 0

  def calc("B X"), do: 1 + 0
  def calc("B Y"), do: 2 + 3
  def calc("B Z"), do: 3 + 6

  def calc("C X"), do: 1 + 6
  def calc("C Y"), do: 2 + 0
  def calc("C Z"), do: 3 + 3

  @doc """
  Part1

  ## Examples

    iex> Day02.part1()
    12276

  """
  def part1 do
    parse()
    |> Enum.map(&calc/1)
    |> Enum.sum()
  end

  def calc2("A X"), do: 0 + 3
  def calc2("A Y"), do: 3 + 1
  def calc2("A Z"), do: 6 + 2

  def calc2("B X"), do: 0 + 1
  def calc2("B Y"), do: 3 + 2
  def calc2("B Z"), do: 6 + 3

  def calc2("C X"), do: 0 + 2
  def calc2("C Y"), do: 3 + 3
  def calc2("C Z"), do: 6 + 1

  @doc """
  Part2

  ## Examples

    iex> Day02.part2()
    9975

  """
  def part2 do
    parse()
    |> Enum.map(&calc2/1)
    |> Enum.sum()
  end
end
