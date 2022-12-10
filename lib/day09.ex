defmodule Day09 do
  def parse do
    File.read!("input/input09.txt")
    |> String.replace("\r\n", "\n")
    |> String.split("\n")
    |> Enum.map(fn l ->
      [dir, count] = String.split(l, " ")
      {dir, String.to_integer(count)}
    end)
  end

  @doc """
  Part1

  ## Examples

    iex> Day09.part1()
    6498

  """
  def part1 do
    parse()
    |> Enum.reduce({{0, 0}, {0, 0}, MapSet.new([{0, 0}])}, &rope_sim1/2)
    |> elem(2)
    |> MapSet.size()
  end

  def move({x, y}, "R"), do: {x + 1, y}
  def move({x, y}, "L"), do: {x - 1, y}
  def move({x, y}, "U"), do: {x, y - 1}
  def move({x, y}, "D"), do: {x, y + 1}

  def rope_sim1({dir, count}, acc) do
    Enum.reduce(1..count, acc, fn
      _, {h, t, cover_map} ->
        nh = move(h, dir)

        nt = move_tail(t, nh)

        {nh, nt, MapSet.put(cover_map, nt)}
    end)
  end

  def compare(a, b) when a > b, do: 1
  def compare(a, b) when a < b, do: -1
  def compare(_a, _b), do: 0

  @doc """
  Part2

  ## Examples

    iex> Day09.part2()
    2531

  """
  def part2 do
    parse()
    |> Enum.reduce(
      {{0, 0}, for(_ <- 1..9, do: {0, 0}), MapSet.new([{0, 0}])},
      &rope_sim2/2
    )
    |> elem(2)
    |> MapSet.size()
  end

  def rope_sim2({dir, count}, acc) do
    Enum.reduce(1..count, acc, fn
      _, {h, t, cover_map} ->
        nh = move(h, dir)

        nt = Enum.scan(t, nh, &move_tail/2)

        {nh, nt, MapSet.put(cover_map, List.last(nt))}
    end)
  end

  def move_tail({tx, ty}, {nhx, nhy}) when abs(nhx - tx) > 1 or abs(nhy - ty) > 1,
    do: {tx + compare(nhx, tx), ty + compare(nhy, ty)}

  def move_tail(t, _), do: t
end
