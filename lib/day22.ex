defmodule Day22 do
  def parse do
    [m, i] =
      File.read!("input/input23t.txt")
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

    # {map_size(map), Day22.Part2.rotate(map) |> map_size ()}
    map
    |> Day22.Part2.rotate(1)
    |> map_size()

    # Enum.reduce(inst, {start, ">"}, &Day22.Part2.move(&1, &2, map))
    # |> password()
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
    def find_rotation_point(map) do
      Map.keys(map)
      |> Enum.filter(fn {x, y} ->
        (Map.has_key?(map, {x + 1, y}) &&
           Map.has_key?(map, {x, y + 1}) &&
           !Map.has_key?(map, {x + 1, y + 1})) ||
          (Map.has_key?(map, {x - 1, y}) &&
             Map.has_key?(map, {x, y + 1}) &&
             !Map.has_key?(map, {x - 1, y + 1})) ||
          (Map.has_key?(map, {x + 1, y}) &&
             Map.has_key?(map, {x, y - 1}) &&
             !Map.has_key?(map, {x + 1, y - 1})) ||
          (Map.has_key?(map, {x - 1, y}) &&
             Map.has_key?(map, {x, y - 1}) &&
             !Map.has_key?(map, {x - 1, y - 1}))
      end)
    end

    def rotate(map, 0) do
      {ax, ay} =
        Map.keys(map)
        |> Enum.find(fn {x, y} ->
          Map.has_key?(map, {x - 1, y}) &&
            Map.has_key?(map, {x, y + 1}) &&
            !Map.has_key?(map, {x - 1, y + 1})
        end)

      {to_r, not_to_r} =
        map
        |> Enum.split_with(fn {{x, y}, _v} -> x < ax and y <= ay end)

      to_r
      |> Enum.sort()
      |> Enum.map(fn {{x, y}, v} -> {{ax - 1 + y - ay, ay + (ax - x)}, v} end)
      |> Map.new()
      |> Map.merge(Map.new(not_to_r))
    end

    def rotate(map, 1) do
      {ax, ay} =
        Map.keys(map)
        |> Enum.find(fn {x, y} ->
          Map.has_key?(map, {x - 1, y}) &&
            Map.has_key?(map, {x, y - 1}) &&
            !Map.has_key?(map, {x - 1, y - 1})
        end)

      {to_r, not_to_r} =
        map
        |> Enum.split_with(fn {{x, y}, _v} -> x >= ax and y < ay end)

      to_r
      |> Enum.sort()
      |> Enum.map(fn {{x, y}, v} -> {{ax + y - ay, ay - 1 + (ax - x)}, v} end)
      |> Map.new()
      |> Map.merge(Map.new(not_to_r))
    end

    def rotate(map, 2) do
      {ax, ay} =
        Map.keys(map)
        |> Enum.find(fn {x, y} ->
          Map.has_key?(map, {x + 1, y}) &&
            Map.has_key?(map, {x, y + 1}) &&
            !Map.has_key?(map, {x + 1, y + 1})
        end)

      {to_r, not_to_r} =
        map
        |> Enum.split_with(fn {{x, y}, _v} -> x <= ax and y < ay end)

      to_r
      |> Enum.sort()
      |> Enum.map(fn {{x, y}, v} -> {{ax - 1 + y - ay, ay + (ax - x)}, v} end)
      |> Map.new()
      |> Map.merge(Map.new(not_to_r))
    end

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
end
