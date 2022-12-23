defmodule Day23 do
  def parse do
    File.read!("input/input23.txt")
    |> String.replace("\r\n", "\n")
    |> String.split("\n")
    |> Enum.with_index(1)
    |> Enum.flat_map(fn {l, y} ->
      String.graphemes(l)
      |> Enum.with_index(1)
      |> Enum.map(fn {c, x} -> {{x, y}, c} end)
    end)
    |> Enum.filter(fn {_, c} -> c == "#" end)
    |> Enum.map(&elem(&1, 0))
    |> MapSet.new()
  end

  @doc """
  Part1
  
  ## Examples
  
    iex> Day23.part1()
    4056
  
  """
  def part1 do
    parse()
    |> run()
    |> coverage()
  end

  @doc """
  Part2
  
  ## Examples
  
    iex> Day23.part2()
    103224
  
  """
  def part2 do
    parse()
    |> run_until_no_move()
  end

  def coverage(map) do
    {x1, x2} = Enum.map(map, &elem(&1, 0)) |> Enum.min_max()
    {y1, y2} = Enum.map(map, &elem(&1, 1)) |> Enum.min_max()

    (x2 - x1 + 1) * (y2 - y1 + 1) - Enum.count(map)
  end

  def run_until_no_move(map, count \\ 0) do
    if Enum.all?(map, &no_need_to_move(&1, map)) do
      count + 1
    else
      run_until_no_move(map |> propose(count) |> move(), count + 1)
    end
  end

  def run(map) do
    for round <- 0..9, reduce: map do
      m ->
        m
        |> propose(round)
        # |> IO.inspect(label: "proposal")
        |> move()
    end
  end

  def propose(map, round) do
    proposals =
      Enum.map(map, fn p ->
        no_need_to_move(p, map) ||
          check(p, round + 0, map) ||
          check(p, round + 1, map) ||
          check(p, round + 2, map) ||
          check(p, round + 3, map)
      end)
      |> Enum.reject(&is_boolean/1)
      |> Map.new()

    {proposals, map}
  end

  def no_need_to_move({x, y}, map) do
    MapSet.new([
      {x - 1, y - 1},
      {x, y - 1},
      {x + 1, y - 1},
      {x - 1, y + 1},
      {x, y + 1},
      {x + 1, y + 1},
      {x - 1, y},
      {x + 1, y}
    ])
    |> MapSet.disjoint?(map)
  end

  def check({x, y} = p, a, map) when rem(a, 4) == 0 do
    MapSet.new([{x - 1, y - 1}, {x, y - 1}, {x + 1, y - 1}])
    |> MapSet.disjoint?(map) &&
      {p, {x, y - 1}}
  end

  def check({x, y} = p, a, map) when rem(a, 4) == 1 do
    MapSet.new([{x - 1, y + 1}, {x, y + 1}, {x + 1, y + 1}])
    |> MapSet.disjoint?(map) &&
      {p, {x, y + 1}}
  end

  def check({x, y} = p, a, map) when rem(a, 4) == 2 do
    MapSet.new([{x - 1, y - 1}, {x - 1, y}, {x - 1, y + 1}])
    |> MapSet.disjoint?(map) &&
      {p, {x - 1, y}}
  end

  def check({x, y} = p, a, map) when rem(a, 4) == 3 do
    MapSet.new([{x + 1, y - 1}, {x + 1, y}, {x + 1, y + 1}])
    |> MapSet.disjoint?(map) &&
      {p, {x + 1, y}}
  end

  def move({proposals, map}) do
    target_count =
      Enum.group_by(proposals, &elem(&1, 1))
      |> Enum.map(fn {k, v} -> {k, Enum.count(v)} end)
      |> Map.new()

    # IO.inspect(target_count, label: "target")

    for elf <- map, reduce: MapSet.new() do
      new_map ->
        if Map.has_key?(proposals, elf) && target_count[proposals[elf]] == 1 do
          MapSet.put(new_map, proposals[elf])
        else
          MapSet.put(new_map, elf)
        end
    end
  end
end
