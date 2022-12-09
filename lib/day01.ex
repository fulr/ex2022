defmodule Day01 do
  def parse do
    File.read!("input/input01.txt")
    |> String.split("\n\n")
    |> Enum.map(fn x ->
      x
      |> String.split("\n")
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.map(&Enum.sum/1)
  end

  @doc """
  Part1

  ## Examples

    iex> Day01.part1()
    70764

  """
  def part1 do
    parse()
    |> Enum.max()
  end

  @doc """
  Part2

  ## Examples

    iex> Day01.part2()
    203905

  """
  def part2 do
    parse()
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.sum()
  end
end
