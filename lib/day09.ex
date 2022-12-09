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

  @dir_map %{"R" => {1, 0}, "L" => {-1, 0}, "U" => {0, -1}, "D" => {0, 1}}

  def rope_sim1({dir, count}, acc) do
    {hdx, hdy} = @dir_map[dir]

    Enum.reduce(1..count, acc, fn
      _, {{hx, hy}, {tx, ty}, cover_map} ->
        nhx = hx + hdx
        nhy = hy + hdy

        {ntx, nty} =
          if abs(nhx - tx) > 1 or abs(nhy - ty) > 1 do
            tdx = compare(nhx, tx)
            tdy = compare(nhy, ty)
            {tx + tdx, ty + tdy}
          else
            {tx, ty}
          end

        {{nhx, nhy}, {ntx, nty}, MapSet.put(cover_map, {ntx, nty})}
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
      {{0, 0}, [{0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}],
       MapSet.new([{0, 0}])},
      &rope_sim2/2
    )
    |> elem(2)
    |> MapSet.size()
  end

  def rope_sim2({dir, count}, acc) do
    {hdx, hdy} = @dir_map[dir]

    Enum.reduce(1..count, acc, fn
      _, {{hx, hy}, t, cover_map} ->
        nh = {hx + hdx, hy + hdy}

        nt =
          Enum.reduce(t, {nh, []}, fn {tx, ty}, {{nhx, nhy}, result} ->
            n =
              if abs(nhx - tx) > 1 or abs(nhy - ty) > 1 do
                tdx = compare(nhx, tx)
                tdy = compare(nhy, ty)
                {tx + tdx, ty + tdy}
              else
                {tx, ty}
              end

            {n, [n | result]}
          end)
          |> elem(1)
          |> Enum.reverse()

        {nh, nt, MapSet.put(cover_map, List.last(nt))}
    end)
  end
end
