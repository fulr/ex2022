defmodule Day22 do
  def parse do
    [m, i] =
      File.read!("input/input22.txt")
      |> String.replace("\r\n", "\n")
      |> String.split("\n\n")

    map =
      m
      |> String.split("\n")
      |> Enum.with_index(1)
      |> Enum.flat_map(fn {l, y} ->
        String.graphemes(l)
        |> Enum.with_index(1)
        |> Enum.map(fn {c, x} -> {{x, y}, c} end)
      end)
      |> Enum.filter(fn {_, c} -> c != " " end)
      |> Map.new()

    inst =
      i
      |> String.split("R")
      |> Enum.map(fn part ->
        part
        |> String.split("L")
        |> Enum.map(&String.to_integer/1)
        |> Enum.intersperse("L")
      end)
      |> Enum.intersperse("R")
      |> List.flatten()

    {map, inst}
  end

  @doc """
  Part1

  ## Examples

    iex> Day22.part1()
    103224

  """
  def part1 do
    {map, inst} = parse()

    start = Map.keys(map) |> Enum.min_by(fn {x, y} -> {y, x} end)

    Enum.reduce(inst, {start, ">"}, &Day22.Part1.move(&1, &2, map))
    |> password()
  end

  def password({{x, y}, dir}) do
    directions = %{">" => 0, "v" => 1, "<" => 2, "^" => 3}
    y * 1000 + x * 4 + directions[dir]
  end

  @doc """
  Part2

  ## Examples

    iex> Day22.part2()
    189097

  """
  def part2 do
    {map, inst} = parse()

    start = Map.keys(map) |> Enum.min_by(fn {x, y} -> {y, x} end)

    Enum.reduce(inst, {start, ">"}, &Day22.Part2.move(&1, &2, map))
    |> password()
  end

  def print(map) do
    {x1, x2} = Enum.map(map, fn {{x, _}, _} -> x end) |> Enum.min_max()
    {y1, y2} = Enum.map(map, fn {{_, y}, _} -> y end) |> Enum.min_max()

    IO.inspect({x1, y1})

    for y <- y1..y2 do
      for x <- x1..x2 do
        IO.write(get_in(map, [{x, y}, :c]) || " ")
      end

      IO.puts("")
    end

    IO.puts("")

    map
  end

  defmodule Part1 do
    def move("R", {pos, ">"}, _map), do: {pos, "v"}
    def move("R", {pos, "v"}, _map), do: {pos, "<"}
    def move("R", {pos, "<"}, _map), do: {pos, "^"}
    def move("R", {pos, "^"}, _map), do: {pos, ">"}

    def move("L", {pos, ">"}, _map), do: {pos, "^"}
    def move("L", {pos, "v"}, _map), do: {pos, ">"}
    def move("L", {pos, "<"}, _map), do: {pos, "v"}
    def move("L", {pos, "^"}, _map), do: {pos, "<"}

    def move(0, state, _map), do: state

    def move(dist, {pos, ">" = dir} = state, map) do
      {x, y} = pos
      pos_next = {x + 1, y}

      next =
        if Map.has_key?(map, pos_next) do
          pos_next
        else
          Map.keys(map)
          |> Enum.filter(fn {_, sy} -> sy == y end)
          |> Enum.min_by(fn {sx, _} -> sx end)
        end

      if map[next] == "." do
        move(dist - 1, {next, dir}, map)
      else
        state
      end
    end

    def move(dist, {pos, "<" = dir} = state, map) do
      {x, y} = pos
      pos_next = {x - 1, y}

      next =
        if Map.has_key?(map, pos_next) do
          pos_next
        else
          Map.keys(map)
          |> Enum.filter(fn {_, sy} -> sy == y end)
          |> Enum.max_by(fn {sx, _} -> sx end)
        end

      if map[next] == "." do
        move(dist - 1, {next, dir}, map)
      else
        state
      end
    end

    def move(dist, {pos, "^" = dir} = state, map) do
      {x, y} = pos
      pos_next = {x, y - 1}

      next =
        if Map.has_key?(map, pos_next) do
          pos_next
        else
          Map.keys(map)
          |> Enum.filter(fn {sx, _} -> sx == x end)
          |> Enum.max_by(fn {_, sy} -> sy end)
        end

      if map[next] == "." do
        move(dist - 1, {next, dir}, map)
      else
        state
      end
    end

    def move(dist, {pos, "v" = dir} = state, map) do
      {x, y} = pos
      pos_next = {x, y + 1}

      next =
        if Map.has_key?(map, pos_next) do
          pos_next
        else
          Map.keys(map)
          |> Enum.filter(fn {sx, _} -> sx == x end)
          |> Enum.min_by(fn {_, sy} -> sy end)
        end

      if map[next] == "." do
        move(dist - 1, {next, dir}, map)
      else
        state
      end
    end
  end

  defmodule Part2 do
    def move("R", {pos, ">"}, _), do: {pos, "v"}
    def move("R", {pos, "v"}, _), do: {pos, "<"}
    def move("R", {pos, "<"}, _), do: {pos, "^"}
    def move("R", {pos, "^"}, _), do: {pos, ">"}

    def move("L", {pos, ">"}, _), do: {pos, "^"}
    def move("L", {pos, "v"}, _), do: {pos, ">"}
    def move("L", {pos, "<"}, _), do: {pos, "v"}
    def move("L", {pos, "^"}, _), do: {pos, "<"}

    def move(0, state, _), do: state

    def move(dist, {pos, dir} = state, map) do
      {next_pos, _} = n = next(pos, dir)

      # IO.inspect(n)

      # Map.has_key?(map, next_pos) || raise "t"

      if map[next_pos] == "." do
        move(dist - 1, n, map)
      else
        state
      end
    end

    def next({x, y}, "^") when x in 1..50 and y == 101, do: {{51, 50 + x}, ">"}
    def next({x, y}, "^") when x in 51..100 and y == 1, do: {{1, 150 + x - 50}, ">"}
    def next({x, y}, "^") when x in 101..150 and y == 1, do: {{x - 100, 200}, "^"}

    def next({x, y}, "v") when x in 1..50 and y == 200, do: {{x + 100, 1}, "v"}
    def next({x, y}, "v") when x in 51..100 and y == 150, do: {{50, 150 + x - 50}, "<"}
    def next({x, y}, "v") when x in 101..150 and y == 50, do: {{100, 50 + x - 100}, "<"}

    def next({x, y}, ">") when y in 1..50 and x == 150, do: {{100, 151 - y}, "<"}
    def next({x, y}, ">") when y in 51..100 and x == 100, do: {{100 + y - 50, 50}, "^"}
    def next({x, y}, ">") when y in 101..150 and x == 100, do: {{150, 51 - (y - 100)}, "<"}
    def next({x, y}, ">") when y in 151..200 and x == 50, do: {{50 + y - 150, 150}, "^"}

    def next({x, y}, "<") when y in 1..50 and x == 51, do: {{1, 151 - y}, ">"}
    def next({x, y}, "<") when y in 51..100 and x == 51, do: {{y - 50, 101}, "v"}
    def next({x, y}, "<") when y in 101..150 and x == 1, do: {{51, 51 - (y - 100)}, ">"}
    def next({x, y}, "<") when y in 151..200 and x == 1, do: {{50 + y - 150, 1}, "v"}

    def next({x, y}, "v"), do: {{x, y + 1}, "v"}
    def next({x, y}, "^"), do: {{x, y - 1}, "^"}
    def next({x, y}, "<"), do: {{x - 1, y}, "<"}
    def next({x, y}, ">"), do: {{x + 1, y}, ">"}
  end
end
