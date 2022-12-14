defmodule Day14 do
  def parse do
    File.read!("input/input14.txt")
    |> String.replace("\r\n", "\n")
    |> String.split("\n")
    |> Enum.map(fn l ->
      String.split(l, " -> ")
      |> Enum.map(fn seg ->
        [x, y] = String.split(seg, ",") |> Enum.map(&String.to_integer/1)
        {x, y}
      end)
    end)
  end

  def build_map(lines) do
    lines
    |> Enum.flat_map(fn line ->
      line
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(&build_line/1)
    end)
    |> Enum.reduce(MapSet.new(), &MapSet.union/2)
  end

  def build_line([{x1, y1}, {x1, y2}]), do: y1..y2 |> Enum.map(&{x1, &1}) |> MapSet.new()
  def build_line([{x1, y1}, {x2, y1}]), do: x1..x2 |> Enum.map(&{&1, y1}) |> MapSet.new()

  def pour_sand(map, {gx, gy} = grain, max_y) do
    cond do
      gy > max_y -> {:off, map}
      !MapSet.member?(map, {gx, gy + 1}) -> pour_sand(map, {gx, gy + 1}, max_y)
      !MapSet.member?(map, {gx - 1, gy + 1}) -> pour_sand(map, {gx - 1, gy + 1}, max_y)
      !MapSet.member?(map, {gx + 1, gy + 1}) -> pour_sand(map, {gx + 1, gy + 1}, max_y)
      true -> {:ok, MapSet.put(map, grain)}
    end
  end

  def pour_all_sand(map, start, max_y) do
    case pour_sand(map, start, max_y) do
      {:ok, m} -> pour_all_sand(m, start, max_y)
      {:off, m} -> m
    end
  end

  @doc """
  Part1

  ## Examples

    iex> Day14.part1()
    793

  """
  def part1 do
    map =
      parse()
      |> build_map()

    max_y =
      Enum.map(map, fn {_, y} -> y end)
      |> Enum.max()

    map_with_sand = pour_all_sand(map, {500, 0}, max_y)

    MapSet.size(map_with_sand) - MapSet.size(map)
  end

  @doc """
  Part2

  ## Examples

    iex> Day14.part2()
    nil

  """
  def part2 do
    map =
      parse()
      |> build_map()

    max_y =
      Enum.map(map, fn {_, y} -> y end)
      |> Enum.max()

    map_with_sand = pour_all_sand2(map, {500, 0}, max_y + 1)

    MapSet.size(map_with_sand) - MapSet.size(map)
  end

  def pour_sand2(map, {gx, gy} = grain, max_y) do
    cond do
      MapSet.member?(map, grain) -> {:off, map}
      gy == max_y -> {:ok, MapSet.put(map, grain)}
      !MapSet.member?(map, {gx, gy + 1}) -> pour_sand2(map, {gx, gy + 1}, max_y)
      !MapSet.member?(map, {gx - 1, gy + 1}) -> pour_sand2(map, {gx - 1, gy + 1}, max_y)
      !MapSet.member?(map, {gx + 1, gy + 1}) -> pour_sand2(map, {gx + 1, gy + 1}, max_y)
      true -> {:ok, MapSet.put(map, grain)}
    end
  end

  def pour_all_sand2(map, start, max_y) do
    case pour_sand2(map, start, max_y) do
      {:ok, m} -> pour_all_sand2(m, start, max_y)
      {:off, m} -> m
    end
  end
end
