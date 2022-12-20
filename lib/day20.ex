defmodule Day20 do
  def parse do
    File.read!("input/input20.txt")
    |> String.replace("\r\n", "\n")
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)
  end

  @doc """
  Part1

  ## Examples

    iex> Day20.part1()
    8372

  """
  def part1 do
    input = parse()
    size = Enum.count(input)
    idx = Enum.to_list(0..(size - 1))

    transformation =
      for {v, i} <- Enum.with_index(input), reduce: idx do
        l ->
          i_in_l = Enum.find_index(l, &(i == &1))
          ins = Integer.mod(i_in_l + v, size - 1)

          cond do
            v == 0 ->
              l

            ins > i_in_l ->
              l |> List.insert_at(ins + 1, i) |> List.delete_at(i_in_l)

            true ->
              l |> List.delete_at(i_in_l) |> List.insert_at(ins, i)
          end
      end

    decrypted = transformation |> Enum.map(&Enum.at(input, &1))

    pos_of_zero = Enum.find_index(decrypted, &(&1 == 0))

    Enum.at(decrypted, Integer.mod(pos_of_zero + 1000, size)) +
      Enum.at(decrypted, Integer.mod(pos_of_zero + 2000, size)) +
      Enum.at(decrypted, Integer.mod(pos_of_zero + 3000, size))
  end

  @doc """
  Part2

  ## Examples

    iex> Day20.part2()
    7865110481723

  """
  def part2 do
    input = parse() |> Enum.map(&(&1 * 811_589_153))
    size = Enum.count(input)
    idx = Enum.to_list(0..(size - 1))

    transformation =
      for _round <- 1..10, {v, i} <- Enum.with_index(input), reduce: idx do
        l ->
          i_in_l = Enum.find_index(l, &(i == &1))
          ins = Integer.mod(i_in_l + v, size - 1)

          cond do
            v == 0 ->
              l

            ins > i_in_l ->
              l |> List.insert_at(ins + 1, i) |> List.delete_at(i_in_l)

            true ->
              l |> List.delete_at(i_in_l) |> List.insert_at(ins, i)
          end
      end

    decrypted = transformation |> Enum.map(&Enum.at(input, &1))

    pos_of_zero = Enum.find_index(decrypted, &(&1 == 0))

    Enum.at(decrypted, Integer.mod(pos_of_zero + 1000, size)) +
      Enum.at(decrypted, Integer.mod(pos_of_zero + 2000, size)) +
      Enum.at(decrypted, Integer.mod(pos_of_zero + 3000, size))
  end
end
