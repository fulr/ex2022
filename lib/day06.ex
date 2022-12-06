defmodule Day06 do
  def parse do
    File.read!("input/input06.txt")
    |> String.to_charlist()
  end

  @doc """
  Part1

  ## Examples

    iex> Day06.part1()
    [{'dcmv', 1080}]

  """
  def part1 do
    Day06.parse()
    |> Enum.chunk_every(4, 1, :discard)
    |> Enum.with_index(4)
    |> Enum.filter(fn {x, _} -> MapSet.new(x) |> MapSet.size() == 4 end)
    |> Enum.take(1)
  end

  @doc """
  Part2

  ## Examples

    iex> Day06.part2()
    [{'sblmzdwqcrftvn', 3645}]

  """
  def part2 do
    Day06.parse()
    |> Enum.chunk_every(14, 1, :discard)
    |> Enum.with_index(14)
    |> Enum.filter(fn {x, _} -> MapSet.new(x) |> MapSet.size() == 14 end)
    |> Enum.take(1)
  end
end
