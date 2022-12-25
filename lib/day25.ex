defmodule Day25 do
  def parse do
    File.read!("input/input25.txt")
    |> String.replace("\r\n", "\n")
    |> String.split("\n")
  end

  @doc """
  Part1
  
  ## Examples
  
    iex> Day25.part1()
    4056
  
  """
  def part1 do
    parse()
    |> Enum.map(&parse/1)
    |> Enum.sum()
    |> format()
  end

  @snafu %{"2" => 2, "1" => 1, "0" => 0, "-" => -1, "=" => -2}
  @rev %{2 => {"2", 0}, 1 => {"1", 0}, 0 => {"0", 0}, 3 => {"=", 1}, 4 => {"-", 1}}

  def parse(s) do
    s
    |> String.graphemes()
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.map(fn {c, p} -> @snafu[c] * 5 ** p end)
    |> Enum.sum()
  end

  def format(0), do: ""

  def format(n) do
    {c, d} = @rev[rem(n, 5)]
    format(div(n, 5) + d) <> c
  end

  @doc """
  Part2
  
  ## Examples
  
    iex> Day25.part2()
    nil
  
  """
  def part2 do
  end
end
