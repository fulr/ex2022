defmodule Day22 do
  def parse do
    File.read!("input/input22t.txt")
    |> String.replace("\r\n", "\n")
    |> String.split("\n")
  end

  @doc """
  Part1

  ## Examples

    iex> Day22.part1()
    232974643455000

  """
  def part1 do
    parse()
  end

  @doc """
  Part2

  ## Examples

    iex> Day22.part2()
    nil

  """
  def part2 do
  end
end
