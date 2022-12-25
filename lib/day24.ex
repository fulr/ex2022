defmodule Day24 do
  def parse do
    File.read!("input/input24.txt")
    |> String.replace("\r\n", "\n")
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.flat_map(fn {l, y} ->
      String.graphemes(l)
      |> Enum.with_index()
      |> Enum.map(fn {c, x} -> {{x - 1, y - 1}, c} end)
    end)
    |> Map.new()
  end

  @doc """
  Part1
  
  ## Examples
  
    iex> Day24.part1()
    249
  
  """
  def part1 do
    parse()
    |> build_start()
    # |> IO.inspect(label: 'after build')
    |> find_way()
    |> elem(1)
  end

  def build_start(map) do
    blizzards = Enum.filter(map, fn {_p, c} -> c in [">", "<", "v", "^"] end)
    max_x = Enum.map(map, fn {{x, _y}, _} -> x end) |> Enum.max()
    max_y = Enum.map(map, fn {{_x, y}, _} -> y end) |> Enum.max()

    start = {0, -1}
    stop = {max_x - 1, max_y}

    {[{start, 0}], blizzards, stop, max_x, max_y}
  end

  def find_way({todo, blizzards, stop, max_x, max_y}),
    do: find_way(todo, blizzards, stop, max_x, max_y)

  def find_way(todo, blizzards, {sx, sy} = stop, max_x, max_y, visited \\ MapSet.new()) do
    [{{mx, my} = me, time} | rest] = todo
    # |> Enum.sort_by(fn {{x1, y1}, _, time, {x2, y2}} ->
    #   {time, abs(x1 - x2) + abs(y1 - y2)}
    # end)

    # IO.inspect(time, label: 'time')
    # IO.inspect(me, label: 'me')

    visited_key = {me, time}

    cond do
      me == stop ->
        {me, time}

      MapSet.member?(visited, visited_key) ->
        find_way(rest, blizzards, stop, max_x, max_y, visited)

      blizzard?(blizzards, me, time, max_x, max_y) ->
        find_way(rest, blizzards, stop, max_x, max_y, MapSet.put(visited, visited_key))

      # abs(mx - sx) + abs(my - sy) > 2 * (max_x + max_y) - time ->
      #   find_way(rest, blizzards, stop, max_x, max_y, visited)

      true ->
        next =
          for {x, y} <- [{mx, my}, {mx - 1, my}, {mx + 1, my}, {mx, my - 1}, {mx, my + 1}],
              (x in 0..(max_x - 1) &&
                 y in 0..(max_y - 1)) || {x, y} == stop || {x, y} == me do
            {{x, y}, time + 1}
          end

        find_way(rest ++ next, blizzards, stop, max_x, max_y, MapSet.put(visited, visited_key))
    end
  end

  def blizzard?(blizzards, me, time, max_x, max_y) do
    blizzards
    |> Enum.any?(fn {p, dir} ->
      {x, y} = move(p, dir, time)
      me == {Integer.mod(x, max_x), Integer.mod(y, max_y)}
    end)
  end

  def move({x, y}, "v", time), do: {x, y + time}
  def move({x, y}, "^", time), do: {x, y - time}
  def move({x, y}, "<", time), do: {x - time, y}
  def move({x, y}, ">", time), do: {x + time, y}

  @doc """
  Part2
  
  ## Examples
  
    iex> Day24.part2()
    735
  
  """
  def part2 do
    {[{start, 0}], blizzards, stop, max_x, max_y} = parse() |> build_start()

    {_, time1} = find_way({[{start, 0}], blizzards, stop, max_x, max_y})
    {_, time2} = find_way({[{stop, time1}], blizzards, start, max_x, max_y})
    {_, time3} = find_way({[{start, time2}], blizzards, stop, max_x, max_y})
    time3
  end
end
