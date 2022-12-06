defmodule Day01 do
  @doc """
  Part1
  
  ## Examples
  
    iex> Day01.part1()
    70764
  
  """
  def part1 do
    File.read!("input01.txt")
    |> String.split("\r\n\r\n")
    |> Enum.map(fn x ->
      x
      |> String.split("\r\n")
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.map(&Enum.sum/1)
    |> Enum.max()
  end

  @doc """
  Part2
  
  ## Examples
  
    iex> Day01.part2()
    203905
  
  """
  def part2 do
    File.read!("input01.txt")
    |> String.split("\r\n\r\n")
    |> Enum.map(fn x ->
      x
      |> String.split("\r\n")
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.map(&Enum.sum/1)
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.sum()
  end
end
