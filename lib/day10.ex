defmodule Day10 do
  def parse do
    File.read!("input/input10.txt")
    |> String.replace("\r\n", "\n")
    |> String.split("\n")
  end

  @doc """
  Part1

  ## Examples

    iex> Day10.part1()
    13180

  """
  def part1 do
    {signal, _} =
      parse()
      |> Enum.flat_map_reduce(1, &interpret/2)

    [20, 60, 100, 140, 180, 220]
    |> Enum.map(fn c -> c * Enum.at(signal, c - 1) end)
    |> Enum.sum()
  end

  def interpret("noop", reg), do: {[reg], reg}
  def interpret("addx " <> n, reg), do: {[reg, reg], reg + String.to_integer(n)}

  @doc """
  Part2

  ## Examples

    iex> Day10.part2()
    ['#### #### ####  ##  #  #   ##  ##  ###  ',
     '#       # #    #  # #  #    # #  # #  # ',
     '###    #  ###  #    ####    # #  # ###  ',
     '#     #   #    #    #  #    # #### #  # ',
     '#    #    #    #  # #  # #  # #  # #  # ',
     '#### #### #     ##  #  #  ##  #  # ###  ']

  """
  def part2 do
    {signal, _} =
      parse()
      |> Enum.flat_map_reduce(1, &interpret/2)

    Enum.take(signal, 240)
    |> Enum.with_index()
    |> Enum.map(fn {reg, idx} -> if(abs(reg - rem(idx, 40)) <= 1, do: ?#, else: 32) end)
    |> Enum.chunk_every(40)
  end
end
