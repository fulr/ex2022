defmodule Day13 do
  def parse do
    File.read!("input/input13.txt")
    |> String.replace("\r\n", "\n")
    |> String.split("\n\n")
    |> Enum.map(fn l ->
      String.split(l, "\n") |> Enum.map(fn x -> Code.eval_string(x) |> elem(0) end)
    end)
  end

  def right_order?(l, r) when is_integer(l) and is_integer(r) and l < r, do: :yes
  def right_order?(l, r) when is_integer(l) and is_integer(r) and l > r, do: :no
  def right_order?(l, r) when is_integer(l) and is_integer(r) and l == r, do: :next

  def right_order?(l, r) when is_integer(l) and is_list(r), do: right_order?([l], r)
  def right_order?(l, r) when is_integer(r) and is_list(l), do: right_order?(l, [r])

  def right_order?([], [_ | _]), do: :yes
  def right_order?([], []), do: :next
  def right_order?([_ | _], []), do: :no

  def right_order?([lh | l], [rh | r]) do
    case right_order?(lh, rh) do
      :next -> right_order?(l, r)
      x -> x
    end
  end

  @doc """
  Part1

  ## Examples

    iex> Day13.part1()
    5760

  """
  def part1 do
    parse()
    |> Enum.with_index(1)
    |> Enum.filter(fn {[l, r], _} -> right_order?(l, r) == :yes end)
    |> Enum.map(fn {_, i} -> i end)
    |> Enum.sum()
  end

  @doc """
  Part2

  ## Examples

    iex> Day13.part2()
    377

  """
  def part2 do
    (parse() ++ [[[[2]], [[6]]]])
    |> Enum.flat_map(fn x -> x end)
    |> Enum.sort(fn l, r -> right_order?(l, r) == :yes end)
    |> Enum.with_index(1)
    |> Enum.filter(fn
      {[[2]], _} -> true
      {[[6]], _} -> true
      _ -> false
    end)
    |> Enum.map(fn {_, i} -> i end)
    |> Enum.product()
  end
end
