defmodule Day17 do
  def parse do
    File.read!("input/input17.txt")
  end

  @minus [{0, 0}, {1, 0}, {2, 0}, {3, 0}]
  @plus [{1, 0}, {0, 1}, {1, 1}, {2, 1}, {1, 2}]
  @bigl [{0, 0}, {1, 0}, {2, 0}, {2, 1}, {2, 2}]
  @rod [{0, 0}, {0, 1}, {0, 2}, {0, 3}]
  @block [{0, 0}, {1, 0}, {0, 1}, {1, 1}]

  @shapes [@minus, @plus, @bigl, @rod, @block]

  @start_map MapSet.new([{0, 0}, {1, 0}, {2, 0}, {3, 0}, {4, 0}, {5, 0}, {6, 0}])

  @doc """
  Part1

  ## Examples

    iex> Day17.part1()
    3127

  """
  def part1 do
    wind = parse() |> String.to_charlist()
    wind_size = Enum.count(wind)
    shapes = Stream.cycle(@shapes)

    Stream.take(shapes, 2022)
    |> Enum.reduce({0, @start_map}, fn s, {i, m} ->
      {next_i, last_shape} = new_shape(m, s) |> fall(i, wind, wind_size, m)
      {next_i, MapSet.new(last_shape) |> MapSet.union(m)}
    end)
    |> elem(1)
    |> Enum.max_by(fn {_, y} -> y end)
    |> elem(1)
  end

  def new_shape(m, shape) do
    {_, max_y} = Enum.max_by(m, fn {_, y} -> y end)
    translate(shape, {2, max_y + 4})
  end

  def translate(shape, {u, v}), do: Enum.map(shape, fn {x, y} -> {x + u, y + v} end)

  def apply_wind(shape, ?<, map) do
    next = translate(shape, {-1, 0})

    if Enum.any?(next, fn {x, _} = p -> x < 0 or MapSet.member?(map, p) end) do
      shape
    else
      next
    end
  end

  def apply_wind(shape, ?>, map) do
    next = translate(shape, {1, 0})

    if Enum.any?(next, fn {x, _} = p -> x > 6 or MapSet.member?(map, p) end) do
      shape
    else
      next
    end
  end

  def down(shape) do
    translate(shape, {0, -1})
  end

  def fall(shape, i, wind, wind_size, map) do
    after_wind = apply_wind(shape, Enum.at(wind, rem(i, wind_size)), map)
    after_down = down(after_wind)

    if Enum.any?(after_down, fn p -> MapSet.member?(map, p) end) do
      {i + 1, after_wind}
    else
      fall(after_down, i + 1, wind, wind_size, map)
    end
  end

  @doc """
  Part2

  ## Examples

    iex> Day17.part2()
    nil

  """
  def part2 do
    wind = parse() |> String.to_charlist()
    wind_size = Enum.count(wind)

    sim2(0, 0, @start_map, Map.new(), 0, 0, wind, wind_size)
  end

  def sim2(s, _, m, _, delta_s, delta_y, _, _) when s + delta_s == 1_000_000_000_000 do
    {_, max_y} = Enum.max_by(m, fn {_, y} -> y end)
    delta_y + max_y
  end

  def sim2(s, i, m, cache, delta_s, delta_y, wind, wind_size) do
    {_, max_y} = Enum.max_by(m, fn {_, y} -> y end)
    fp = fingerprint(m, max_y)
    cache_key = {rem(i, wind_size), rem(s, 5), fp}

    {delta_s, delta_y} =
      if delta_s == 0 and delta_y == 0 and Map.has_key?(cache, cache_key) do
        {last_my, last_s} = cache[cache_key]
        IO.puts("#{} #{max_y} #{s} -- hit")
        delta = s - last_s
        factor = div(1_000_000_000_000 - s, delta)
        {factor * delta, factor * (max_y - last_my)}
      else
        {0, 0}
      end

    {next_i, last_shape} =
      new_shape(m, Enum.at(@shapes, rem(s, 5))) |> fall(i, wind, wind_size, m)

    sim2(
      s + 1,
      next_i,
      MapSet.new(last_shape) |> MapSet.union(m),
      Map.put(cache, cache_key, {max_y, s}),
      delta_s,
      delta_y,
      wind,
      wind_size
    )
  end

  def fingerprint(map, max_y) do
    Enum.filter(map, fn {_, y} -> y > max_y - 20 end)
    |> translate({0, -max_y})
    |> MapSet.new()
  end
end
