defmodule Day08 do
  def parse do
    File.read!("input/input08.txt")
    |> String.replace("\r\n", "\n")
    |> String.split("\n")
    |> Enum.map(fn l ->
      String.graphemes(l)
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index(fn t, i -> {i, t} end)
      |> Map.new()
    end)
    |> Enum.with_index(fn t, i -> {i, t} end)
    |> Map.new()
  end

  @doc """
  Part1

  ## Examples

    iex> Day08.part1()
    1763

  """
  def part1 do
    map = parse()

    max_y = Map.keys(map) |> Enum.max()

    max_x =
      Map.keys(map[0])
      |> Enum.max()

    Enum.reduce(0..max_x, 0, fn x, acc ->
      Enum.reduce(0..max_y, acc, fn y, acc ->
        if is_visible(x, y, map, max_x, max_y), do: acc + 1, else: acc
      end)
    end)
  end

  def is_visible(x, y, map, max_x, max_y) do
    current_height = map[y][x]

    Enum.all?(0..x, fn cx -> map[y][cx] < current_height or cx == x end) or
      Enum.all?(x..max_x, fn cx -> map[y][cx] < current_height or cx == x end) or
      Enum.all?(0..y, fn cy -> map[cy][x] < current_height or cy == y end) or
      Enum.all?(y..max_y, fn cy -> map[cy][x] < current_height or cy == y end)
  end

  @doc """
  Part2

  ## Examples

    iex> Day08.part2()
    nil

  """
  def part2 do
    map = parse()

    max_y = Map.keys(map) |> Enum.max()

    max_x =
      Map.keys(map[0])
      |> Enum.max()

    Enum.flat_map(1..(max_x - 1), fn x ->
      Enum.map(1..(max_y - 1), fn y ->
        scenic_score(x, y, map, max_x, max_y)
      end)
    end)
    |> Enum.max()
  end

  def scenic_score(x, y, map, max_x, max_y) do
    current_height = map[y][x]

    [
      Enum.reduce_while((x + 1)..max_x, 0, fn cx, count ->
        if map[y][cx] < current_height, do: {:cont, count + 1}, else: {:halt, count + 1}
      end),
      Enum.reduce_while((x - 1)..0, 0, fn cx, count ->
        if map[y][cx] < current_height, do: {:cont, count + 1}, else: {:halt, count + 1}
      end),
      Enum.reduce_while((y + 1)..max_y, 0, fn cy, count ->
        if map[cy][x] < current_height, do: {:cont, count + 1}, else: {:halt, count + 1}
      end),
      Enum.reduce_while((y - 1)..0, 0, fn cy, count ->
        if map[cy][x] < current_height, do: {:cont, count + 1}, else: {:halt, count + 1}
      end)
    ]
    |> Enum.product()
  end
end
