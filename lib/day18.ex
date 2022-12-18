defmodule Day18 do
  def parse do
    File.read!("input/input18.txt")
    |> String.replace("\r\n", "\n")
    |> String.split("\n")
    |> Enum.map(fn x ->
      x
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.map(fn [x, y, z] -> {x, y, z} end)
    |> MapSet.new()
  end

  @doc """
  Part1

  ## Examples

    iex> Day18.part1()
    3466

  """
  def part1 do
    parse()
    |> count()
  end

  def count(map), do: Enum.map(map, &count(&1, map)) |> Enum.sum()

  def count(a, map) when is_tuple(a) do
    neighbors(a)
    |> Enum.count(&(!MapSet.member?(map, &1)))
  end

  def neighbors({x, y, z}) do
    [
      {x + 1, y, z},
      {x - 1, y, z},
      {x, y + 1, z},
      {x, y - 1, z},
      {x, y, z + 1},
      {x, y, z - 1}
    ]
  end

  @doc """
  Part2

  ## Examples

    iex> Day18.part2()
    nil

  """
  def part2 do
    scan = parse()

    outside =
      scan
      |> Enum.flat_map(&neighbors/1)
      |> Enum.filter(&(!MapSet.member?(scan, &1)))
      |> MapSet.new()
      |> MapSet.filter(&find_way(scan, [&1]))

    count_outside(scan, outside)
  end

  def count_outside(map, outside),
    do: Enum.map(map, &count_outside(&1, map, outside)) |> Enum.sum()

  def count_outside(a, _map, outside) do
    neighbors(a)
    |> Enum.count(fn p -> MapSet.member?(outside, p) end)
  end

  def find_way(scan, todo, visited \\ MapSet.new())

  def find_way(_, [], _), do: false

  def find_way(scan, todo, visited) do
    [current | rest] = Enum.sort_by(todo, fn {x, y, z} -> abs(x) + abs(y) + abs(z) end)

    cond do
      current == {0, 0, 0} ->
        true

      MapSet.member?(visited, current) ->
        find_way(scan, rest, visited)

      true ->
        find_way(scan, rest ++ free_neighbors(scan, current), MapSet.put(visited, current))
    end
  end

  def free_neighbors(scan, current) do
    neighbors(current)
    |> Enum.filter(&(!MapSet.member?(scan, &1)))
  end
end
