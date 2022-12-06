defmodule Day04 do
  def parse do
    File.read!("input04.txt")
    |> String.split("\r\n")
    |> Enum.map(fn line ->
      line
      |> String.split(",")
      |> Enum.map(fn p -> p |> String.split("-") |> Enum.map(&String.to_integer/1) end)
    end)
  end

  @doc """
  Part1
  
  ## Examples
  
    iex> Day04.part1()
    576
  
  """
  def part1 do
    Day04.parse()
    |> Enum.filter(&Day04.filter/1)
    |> Enum.count()
  end

  def filter([[a, b], [c, d]]) when a <= c and b >= d, do: true
  def filter([[a, b], [c, d]]) when c <= a and d >= b, do: true
  def filter(_), do: false

  @doc """
  Part2
  
  ## Examples
  
    iex> Day04.part2()
    905
  
  """
  def part2 do
    Day04.parse()
    |> Enum.filter(&Day04.filter2/1)
    |> Enum.count()
  end

  def filter2([[a, b], [c, d]]) when a <= d and b >= c, do: true
  def filter2(_), do: false
end
