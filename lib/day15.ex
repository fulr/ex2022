defmodule Day15 do
  def parse do
    File.read!("input/input15.txt")
    |> String.replace("\r\n", "\n")
    |> String.split("\n")
    |> Enum.map(fn l ->
      Regex.run(~r/Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)/, l,
        capture: :all_but_first
      )
      |> Enum.map(&String.to_integer/1)
    end)
  end

  def range_on_line([sx, sy, bx, by], y_line) do
    manhattan_dist = abs(sx - bx) + abs(sy - by)
    dist_to_line = abs(sy - y_line)

    rest_dist_on_line = manhattan_dist - dist_to_line

    if rest_dist_on_line >= 0 do
      (sx - rest_dist_on_line)..(sx + rest_dist_on_line)
    else
      nil
    end
  end

  @doc """
  Part1

  ## Examples

    iex> Day15.part1()
    4951427

  """
  def part1 do
    line = 2_000_000

    map = parse()

    ranges = Enum.map(map, &range_on_line(&1, line))

    nr_of_beacons =
      map
      |> Enum.reduce(MapSet.new(), fn [_, _, x, y], acc ->
        if(line == y, do: MapSet.put(acc, x), else: acc)
      end)
      |> MapSet.size()

    {a, b} =
      Enum.flat_map(ranges, fn
        a..b -> [a, b]
        nil -> []
      end)
      |> Enum.min_max()

    area = b - a + 1

    area - nr_of_beacons
  end

  @doc """
  Part2

  ## Examples

    iex> Day15.part2()
    13029714573243

  """
  def part2 do
    map = parse()

    search_range = 0..4_000_000

    search_range
    |> Enum.reduce_while(nil, fn y, _ ->
      ranges =
        map
        |> Enum.map(&range_on_line(&1, y))
        |> Enum.reduce([search_range], &range_diff/2)

      c = ranges |> Enum.map(&Range.size/1) |> Enum.sum()

      if c == 1 do
        {:halt, {ranges, y}}
      else
        {:cont, nil}
      end
    end)
    |> tuning_freq()
  end

  def tuning_freq({[x..x], y}), do: x * 4_000_000 + y

  @doc """
  diff

  ## Examples

    iex> Day15.range_diff(2..5,1..6)
    []
    iex> Day15.range_diff(1..6,1..6)
    []
    iex> Day15.range_diff(1..6,3..8)
    [1..2]
    iex> Day15.range_diff(1..6,6..8)
    [1..5]
    iex> Day15.range_diff(1..16,3..8)
    [1..2,9..16]
    iex> Day15.range_diff(1..16,-3..5)
    [6..16]
    iex> Day15.range_diff(1..16,-3..1)
    [2..16]
    iex> Day15.range_diff(1..16,-3..0)
    [1..16]

  """
  def range_diff(nil, x), do: x
  def range_diff(a..b, c..d) when a <= b and b < c and c <= d, do: [a..b]
  def range_diff(a..b, c..d) when c <= d and d < a and a <= b, do: [a..b]
  def range_diff(a..b, c..d) when a < c and c <= b and b <= d, do: [a..(c - 1)]
  def range_diff(a..b, c..d) when c <= a and a <= b and b <= d, do: []
  def range_diff(a..b, c..d) when c <= a and a <= d and d < b, do: [(d + 1)..b]
  def range_diff(a..b, c..d) when a < c and c <= d and d < b, do: [a..(c - 1), (d + 1)..b]

  def range_diff(_.._ = r, l) when is_list(l) do
    Enum.flat_map(l, &range_diff(&1, r))
  end
end
