defmodule Day10 do
  def parse do
    File.stream!("input/input10.txt", [], :line)
    |> Stream.map(&String.trim/1)
    |> Stream.transform(1, &interpret/2)
  end

  @doc """
  Part1

  ## Examples

    iex> Day10.part1()
    13180

  """
  def part1 do
    signal = parse()

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
    parse()
    |> Enum.take(240)
    |> Enum.with_index()
    |> Enum.map(fn
      {reg, idx} when rem(idx, 40) in (reg - 1)..(reg + 1) -> ?#
      _ -> ?\s
    end)
    |> Enum.chunk_every(40)
  end
end
