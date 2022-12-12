defmodule Day12 do
  def parse do
    File.read!("input/input12.txt")
    |> String.replace("\r\n", "\n")
    |> String.split("\n")
    |> Enum.map(&String.to_charlist/1)
    |> Enum.with_index()
    |> Enum.flat_map(fn {l, y} -> Enum.with_index(l, fn e, x -> {{x, y}, e} end) end)
    |> Map.new()
  end

  @doc """
  Part1

  ## Examples

    iex> Day12.part1()
    383

  """
  def part1 do
    topo = parse()

    start = Map.filter(topo, fn {_k, v} -> v == ?S end) |> Map.keys() |> hd()
    stop = Map.filter(topo, fn {_k, v} -> v == ?E end) |> Map.keys() |> hd()

    find_shortest_path(
      %{topo | start => ?a, stop => ?z},
      %{start => 0},
      [start],
      %{},
      stop
    )
  end

  def find_shortest_path(topo, dist, todo, visited, stop) do
    current = Enum.min_by(todo, fn e -> Map.get(dist, e, 100_000_000) end)

    if current == stop do
      dist[stop]
    else
      {cx, cy} = current
      current_height = Map.get(topo, current)
      current_dist = Map.get(dist, current)

      n_visited = Map.put(visited, current, true)

      neighbors =
        Map.filter(topo, fn
          {{x, y}, v}
          when ((x in (cx - 1)..(cx + 1) and y == cy and x != cx) or
                  (y in (cy - 1)..(cy + 1) and cx == x and y != cy)) and
                 v <= current_height + 1 ->
            true

          _ ->
            false
        end)
        |> Map.keys()

      to_update =
        Enum.filter(neighbors, &(!Map.has_key?(dist, &1) or dist[&1] > current_dist + 1))

      n_todo =
        Enum.filter(neighbors, &(!Map.get(n_visited, &1, false))) ++
          Enum.filter(todo, &(&1 != current))

      n_dist = Map.merge(dist, Map.from_keys(to_update, current_dist + 1))

      find_shortest_path(topo, n_dist, n_todo, n_visited, stop)
    end
  end

  @doc """
  Part2

  ## Examples

    iex> Day12.part2()
    nil

  """
  def part2 do
    topo = parse()

    start = Map.filter(topo, fn {_k, v} -> v == ?S end) |> Map.keys() |> hd()
    stop = Map.filter(topo, fn {_k, v} -> v == ?E end) |> Map.keys() |> hd()

    topo = %{topo | start => ?a, stop => ?z}

    find_shortest_path_rev(topo, %{stop => 0}, [stop], %{})
  end

  def find_shortest_path_rev(topo, dist, todo, visited) do
    current = Enum.min_by(todo, fn e -> Map.get(dist, e, 100_000_000) end)

    if topo[current] == ?a do
      dist[current]
    else
      {cx, cy} = current
      current_height = Map.get(topo, current)
      current_dist = Map.get(dist, current)

      n_visited = Map.put(visited, current, true)

      neighbors =
        Map.filter(topo, fn
          {{x, y}, v}
          when ((x in (cx - 1)..(cx + 1) and y == cy and x != cx) or
                  (y in (cy - 1)..(cy + 1) and cx == x and y != cy)) and
                 current_height <= v + 1 ->
            true

          _ ->
            false
        end)
        |> Map.keys()

      to_update =
        Enum.filter(neighbors, &(!Map.has_key?(dist, &1) or dist[&1] > current_dist + 1))

      n_todo =
        Enum.filter(neighbors, &(!Map.get(n_visited, &1, false))) ++
          Enum.filter(todo, &(&1 != current))

      n_dist = Map.merge(dist, Map.from_keys(to_update, current_dist + 1))

      find_shortest_path_rev(topo, n_dist, n_todo, n_visited)
    end
  end
end
