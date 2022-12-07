defmodule Day06 do
  def parse do
    File.read!("input/input06.txt")
    |> String.to_charlist()
  end

  def run(header_size) do
    Day06.parse()
    |> Enum.chunk_every(header_size, 1, :discard)
    |> Enum.with_index(header_size)
    |> Enum.filter(fn {x, _} -> MapSet.new(x) |> MapSet.size() == header_size end)
    |> hd()
    |> elem(1)
  end

  @doc """
  Part1

  ## Examples

    iex> Day06.part1()
    1080

  """
  def part1 do
    Day06.run(4)
  end

  @doc """
  Part2

  ## Examples

    iex> Day06.part2()
    3645

  """
  def part2 do
    Day06.run(14)
  end
end
