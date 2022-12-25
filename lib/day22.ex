defmodule Day22 do
  def parse do
    [m, i] =
      File.read!("input/input22t.txt")
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
    nil

  """
  def part2 do
    {map, inst} = parse()

    start = Map.keys(map) |> Enum.min_by(fn {x, y} -> {y, x} end)

    map = Enum.map(map, fn {p, c} -> {p, %{p: p, c: c}} end) |> Map.new()

    {pos, dir, final_map} = Enum.reduce(inst, {start, ">", map}, &Day22.Part2.move(&1, &2))

    print(final_map)

    IO.inspect(pos)

    password({final_map[pos].p, dir})
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
    def rotate(map, 0) do
      case Map.keys(map)
           |> Enum.find(fn {x, y} ->
             Map.has_key?(map, {x - 1, y}) &&
               Map.has_key?(map, {x, y + 1}) &&
               !Map.has_key?(map, {x - 1, y + 1})
           end) do
        nil ->
          nil

        {ax, ay} ->
          {to_r, not_to_r} =
            map
            |> Enum.split_with(fn {{x, y}, _v} -> x < ax and y <= ay end)

          to_r
          |> Enum.sort()
          |> Enum.map(fn {{x, y}, v} -> {{ax - 1 + y - ay, ay + (ax - x)}, v} end)
          # |> IO.inspect(label: "rot 0")
          |> Map.new()
          |> Map.merge(Map.new(not_to_r))
      end
    end

    def rotate(map, 1) do
      case Map.keys(map)
           |> Enum.find(fn {x, y} ->
             Map.has_key?(map, {x - 1, y}) &&
               Map.has_key?(map, {x, y - 1}) &&
               !Map.has_key?(map, {x - 1, y - 1})
           end) do
        nil ->
          nil

        {ax, ay} ->
          {to_r, not_to_r} =
            map
            |> Enum.split_with(fn {{x, y}, _v} -> x >= ax and y < ay end)

          to_r
          |> Enum.sort()
          |> Enum.map(fn {{x, y}, v} -> {{ax + y - ay, ay - 1 + (ax - x)}, v} end)
          # |> IO.inspect(label: "rot 1")
          |> Map.new()
          |> Map.merge(Map.new(not_to_r))
      end
    end

    def rotate(map, 2) do
      case Map.keys(map)
           |> Enum.find(fn {x, y} ->
             Map.has_key?(map, {x + 1, y}) &&
               Map.has_key?(map, {x, y + 1}) &&
               !Map.has_key?(map, {x + 1, y + 1})
           end) do
        nil ->
          nil

        {ax, ay} ->
          {to_r, not_to_r} =
            map
            |> Enum.split_with(fn {{x, y}, _v} -> x <= ax and y > ay end)

          to_r
          |> Enum.sort()
          |> Enum.map(fn {{x, y}, v} -> {{ax + y - ay, ay + 1 + (ax - x)}, v} end)
          |> Map.new()
          |> Map.merge(Map.new(not_to_r))
      end
    end

    def rotate(map, 3) do
      case Map.keys(map)
           |> Enum.find(fn {x, y} ->
             Map.has_key?(map, {x + 1, y}) &&
               Map.has_key?(map, {x, y - 1}) &&
               !Map.has_key?(map, {x + 1, y - 1})
           end) do
        nil ->
          nil

        {ax, ay} ->
          {to_r, not_to_r} =
            map
            |> Enum.split_with(fn {{x, y}, _v} -> x > ax and y >= ay end)

          to_r
          |> Enum.sort()
          |> Enum.map(fn {{x, y}, v} -> {{ax + 1 + y - ay, ay + (ax - x)}, v} end)
          |> Map.new()
          |> Map.merge(Map.new(not_to_r))
      end
    end

    def move("R", {pos, ">", map}), do: {pos, "v", map}
    def move("R", {pos, "v", map}), do: {pos, "<", map}
    def move("R", {pos, "<", map}), do: {pos, "^", map}
    def move("R", {pos, "^", map}), do: {pos, ">", map}

    def move("L", {pos, ">", map}), do: {pos, "^", map}
    def move("L", {pos, "v", map}), do: {pos, ">", map}
    def move("L", {pos, "<", map}), do: {pos, "v", map}
    def move("L", {pos, "^", map}), do: {pos, "<", map}

    def move(0, state), do: state

    def move(dist, {pos, dir, map}) do
      next_pos = next(pos, dir)

      next_map = juggle_map(map, pos, next_pos)

      if next_map[next_pos].c == "." do
        move(dist - 1, {next_pos, dir, next_map})
      else
        {next_pos, dir, next_map}
      end
    end

    def juggle_map(map, current, next, r \\ 0) do
      candidate = rotate(map, r)

      cond do
        Map.has_key?(map, current) && Map.has_key?(map, next) ->
          map

        is_nil(candidate) || !Map.has_key?(candidate, current) ->
          juggle_map(map, current, next, rem(r + 1, 4))

        Map.has_key?(candidate, current) && Map.has_key?(candidate, next) ->
          candidate

        true ->
          juggle_map(candidate, current, next, r)
      end
    end

    def next({x, y}, "v"), do: {x, y + 1}
    def next({x, y}, "^"), do: {x, y - 1}
    def next({x, y}, "<"), do: {x - 1, y}
    def next({x, y}, ">"), do: {x + 1, y}
  end
end
